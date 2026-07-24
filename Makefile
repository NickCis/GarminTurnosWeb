# Default SDK path — override: make SDK=/path/to/connectiq-sdk-lin-...
SDK ?= $(HOME)/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.2.0-2026-06-09-92a1605b2
MONKEYC := $(SDK)/bin/monkeyc
MONKEYDO := $(SDK)/bin/monkeydo
CONNECTIQ := $(SDK)/bin/connectiq

DEVICE ?= fenix7s
# Devices used to bake Monkey Motion mappings (must be installed locally).
# Exclude fr55: 8-color MIP is unsupported by Monkey Motion.
COMMON_DEVICES ?= fr245:fr245m:fr255:fr255m:fr255s:fr255sm:fr265:fr265s:fr745:fr945:fr945lte:fr955:fr965:fenix5plus:fenix5splus:fenix5xplus:fenix6:fenix6pro:fenix6s:fenix6spro:fenix6xpro:fenix7:fenix7s:fenix7x:fenix7pro:fenix7spro:fenix7xpro:epix2:epix2pro42mm:epix2pro47mm:epix2pro51mm:fenix843mm:fenix847mm:fenix8solar47mm:fenix8solar51mm:vivoactive3:vivoactive3m:vivoactive4:vivoactive4s:vivoactive5:venu:venusq:venusqm:venu2:venu2s:venu2plus:venusq2:venusq2m:venu3:venu3s
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
