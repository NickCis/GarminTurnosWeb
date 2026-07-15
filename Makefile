# Default SDK path — override: make SDK=/path/to/connectiq-sdk-lin-...
SDK ?= $(HOME)/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.2.0-2026-06-09-92a1605b2
MONKEYC := $(SDK)/bin/monkeyc
MONKEYDO := $(SDK)/bin/monkeydo
CONNECTIQ := $(SDK)/bin/connectiq

DEVICE ?= fenix7s
COMMON_DEVICES ?= fenix7s:fenix7:fenix7x:fr255s:fr255:fr265s:fr265:fr955:fr965:venu3s:venu3:epix2
KEY ?= private_key.der
OUT ?= TurnosWeb.prg

SETTINGS_SRC := $(patsubst %.prg,%-settings.json,$(OUT))
APP_BASE := $(basename $(notdir $(OUT)))
SETTINGS_VPATH := GARMIN/Settings/$(shell echo $(APP_BASE) | tr '[:lower:]' '[:upper:]')-settings.json

.PHONY: build run simulator release animations

build:
	$(MONKEYC) -f monkey.jungle -o $(OUT) -y $(KEY) -d $(DEVICE) -w

release:
	$(MONKEYC) -f monkey.jungle -o $(basename $(OUT)).iq -y $(KEY) -e -r -w

simulator:
	$(CONNECTIQ)

run: build
	@echo "Start the Connect IQ Simulator first (e.g. make simulator in another terminal), then this loads $(OUT) on $(DEVICE)."
	@if [ ! -f "$(SETTINGS_SRC)" ]; then echo "Missing $(SETTINGS_SRC); rebuild failed to emit app settings metadata." >&2; exit 1; fi
	$(MONKEYDO) $(OUT) $(DEVICE) -a "$(SETTINGS_SRC):$(SETTINGS_VPATH)"

animations:
	$(SDK)/bin/monkeym -v resources/animations/loading-spinner.gif -d $(COMMON_DEVICES) -f 10 -c 6 -p 1 -q 3 -o resources/animations -e LoadingSpinner -w
