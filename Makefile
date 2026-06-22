# Default SDK path — override: make SDK=/path/to/connectiq-sdk-lin-...
SDK ?= $(HOME)/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b
MONKEYC := $(SDK)/bin/monkeyc
MONKEYDO := $(SDK)/bin/monkeydo
CONNECTIQ := $(SDK)/bin/connectiq

DEVICE ?= fenix7s
KEY ?= private_key.der
OUT ?= TurnosWeb.prg

SETTINGS_SRC := $(patsubst %.prg,%-settings.json,$(OUT))
APP_BASE := $(basename $(notdir $(OUT)))
SETTINGS_VPATH := GARMIN/Settings/$(shell echo $(APP_BASE) | tr '[:lower:]' '[:upper:]')-settings.json

.PHONY: build run simulator release

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
