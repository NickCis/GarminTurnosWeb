# Default SDK path — override: make SDK=/path/to/connectiq-sdk-lin-...
SDK ?= $(HOME)/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.2.0-2026-06-09-92a1605b2
MONKEYC := $(SDK)/bin/monkeyc
MONKEYDO := $(SDK)/bin/monkeydo
CONNECTIQ := $(SDK)/bin/connectiq

DEVICE ?= fenix7s
# Devices that cannot include Monkey Motion resources (see monkey.jungle).
NO_ANIM_DEVICES ?= fr55 vivoactive3
# Bake MM mappings for every manifest product that is installed locally,
# except NO_ANIM_DEVICES. Override with COMMON_DEVICES=... if needed.
COMMON_DEVICES ?= $(shell python3 -c 'import os,re; \
m=open("manifest.template.xml").read(); \
prods=re.findall(r"<iq:product id=\"([^\"]+)\"", m); \
skip=set("$(NO_ANIM_DEVICES)".split()); \
inst=set(os.listdir(os.path.expanduser("~/.Garmin/ConnectIQ/Devices"))); \
print(":".join(p for p in prods if p not in skip and p in inst))')
KEY ?= private_key.der
OUT ?= TurnosWeb.prg

# App IDs: beta keeps the historical id; production is a separate Connect IQ app.
VARIANT ?= beta
APP_ID_BETA := c8f2a1b3-4d5e-4f60-9a7b-2e3c4d5f6789
APP_ID_PROD := 78affdbf-bb34-45b3-afeb-5945b7100d40
ifeq ($(VARIANT),prod)
  APP_ID := $(APP_ID_PROD)
  OUT_IQ ?= TurnosWeb-prod.iq
else ifeq ($(VARIANT),beta)
  APP_ID := $(APP_ID_BETA)
  OUT_IQ ?= TurnosWeb-beta.iq
else
  $(error VARIANT must be 'beta' or 'prod' (got '$(VARIANT)'))
endif

MANIFEST_TEMPLATE := manifest.template.xml
MANIFEST := manifest.xml

SETTINGS_SRC := $(patsubst %.prg,%-settings.json,$(OUT))
APP_BASE := $(basename $(notdir $(OUT)))
SETTINGS_VPATH := GARMIN/Settings/$(shell echo $(APP_BASE) | tr '[:lower:]' '[:upper:]')-settings.json

.PHONY: build run simulator release animations icons clean-manifest $(MANIFEST)

# Always regenerate so switching VARIANT=beta|prod updates the id.
$(MANIFEST): $(MANIFEST_TEMPLATE)
	sed 's/__APP_ID__/$(APP_ID)/g' $< > $@
	@echo "Generated $@ (VARIANT=$(VARIANT) APP_ID=$(APP_ID))"

clean-manifest:
	rm -f $(MANIFEST)

build: $(MANIFEST)
	$(MONKEYC) -f monkey.jungle -o $(OUT) -y $(KEY) -d $(DEVICE) -w

release: $(MANIFEST)
	$(MONKEYC) -f monkey.jungle -o $(OUT_IQ) -y $(KEY) -e -r -w

simulator:
	$(CONNECTIQ)

run: build
	@echo "Start the Connect IQ Simulator first (e.g. make simulator in another terminal), then this loads $(OUT) on $(DEVICE)."
	@if [ ! -f "$(SETTINGS_SRC)" ]; then echo "Missing $(SETTINGS_SRC); rebuild failed to emit app settings metadata." >&2; exit 1; fi
	$(MONKEYDO) $(OUT) $(DEVICE) -a "$(SETTINGS_SRC):$(SETTINGS_VPATH)"

animations:
	$(SDK)/bin/monkeym -v resources-anim/animations/loading-spinner.gif -d $(COMMON_DEVICES) -f 10 -c 6 -p 1 -q 3 -o resources-anim/animations -e LoadingSpinner -w

icons:
	python3 scripts/gen_launcher_icons.py
