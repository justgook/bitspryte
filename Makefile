SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ifdef V
Q :=
else
Q := @
MAKEFLAGS += --no-print-directory
endif

.DEFAULT_GOAL := all

BUILD_DIR ?= build.nosync
BIN_NAME ?= bitspryte
BIN := $(BUILD_DIR)/$(BIN_NAME)
GENERATED_DIR := $(BUILD_DIR)/generated
GENERATED_LAYOUT := $(GENERATED_DIR)/layout/layout.odin
GENERATED_SETTINGS_LAYOUT := $(GENERATED_DIR)/settings_layout/settings_layout.odin
GENERATED_LAYOUTS := $(GENERATED_LAYOUT) $(GENERATED_SETTINGS_LAYOUT)
RESOURCE_BUILD_DIR := $(BUILD_DIR)/resources
RESOURCE_STAMP := $(RESOURCE_BUILD_DIR)/.stamp
NATIVE_DIR := $(BUILD_DIR)/native
NATIVE_OBJECT := $(NATIVE_DIR)/native_menu.o
NATIVE_LIBRARY := $(NATIVE_DIR)/libbitspryte_native.a
APP_NAME ?= BitSpryte
APP_DIR := $(BUILD_DIR)/$(APP_NAME).app
APP_CONTENTS := $(APP_DIR)/Contents
APP_STAMP := $(APP_CONTENTS)/.stamp

ODIN ?= odin
PYTHON ?= python3
CLANG ?= xcrun clang
AR ?= ar
MACOSX_DEPLOYMENT_TARGET ?= 14.0
RGUI_LAYOUT ?= rGuiLayout
RGUI_STYLER ?= rGuiStyler
RGUI_ICONS ?= rGuiIcons

ODIN_SOURCES := $(shell find . -path './$(BUILD_DIR)' -prune -o -name '*.odin' -print)
RESOURCE_SOURCES := $(shell find resources -type f -print)
NATIVE_SOURCES := platform/native_menu/native_menu.m platform/native_menu/native_menu.odin
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
NATIVE_DEPS := $(NATIVE_LIBRARY)
NATIVE_LIBRARY_IMPORT := $(shell $(PYTHON) -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$(abspath $(NATIVE_LIBRARY))" "$(abspath platform/native_menu)")
ODIN_NATIVE_FLAGS := -define:NATIVE_MENU_LIB="$(NATIVE_LIBRARY_IMPORT)"
else
NATIVE_DEPS :=
ODIN_NATIVE_FLAGS :=
endif
LAYOUT_SOURCE ?= resources/layouts/main.rgl
SETTINGS_LAYOUT_SOURCE := resources/layouts/settings.rgl
STYLE_SOURCE ?= resources/styles/dark.rgs
ICON_SOURCE ?= resources/icons/bitspryte.rgi

.PHONY: all app check run run-bin generate resources clean layout-edit settings-layout-edit style-edit icons-edit export-raygui-code

ifeq ($(UNAME_S),Darwin)
all: app
else
all: $(BIN)
endif

app: $(APP_STAMP)

generate: $(GENERATED_LAYOUTS)

resources: $(RESOURCE_STAMP)

check: $(GENERATED_LAYOUTS) $(NATIVE_DEPS)
	$(Q)$(ODIN) check . \
		-collection:generated="$(abspath $(GENERATED_DIR))" \
		$(ODIN_NATIVE_FLAGS)

ifeq ($(UNAME_S),Darwin)
run: $(APP_STAMP)
	$(Q)open -n "$(APP_DIR)"
else
run: run-bin
endif

run-bin: $(BIN)
	$(Q)cd "$(BUILD_DIR)" && ./$(BIN_NAME)

$(APP_STAMP): $(BIN) $(RESOURCE_STAMP) platform/macos/Info.plist | $(BUILD_DIR)
	$(Q)echo "Bundling $(APP_NAME).app..."
	$(Q)rm -rf "$(APP_DIR)"
	$(Q)mkdir -p "$(APP_CONTENTS)/MacOS" "$(APP_CONTENTS)/Resources"
	$(Q)cp "$(BIN)" "$(APP_CONTENTS)/MacOS/$(BIN_NAME)"
	$(Q)cp -R "$(RESOURCE_BUILD_DIR)" "$(APP_CONTENTS)/Resources/resources"
	$(Q)cp platform/macos/Info.plist "$(APP_CONTENTS)/Info.plist"
	$(Q)touch "$@"

$(BIN): $(ODIN_SOURCES) $(GENERATED_LAYOUTS) $(RESOURCE_STAMP) $(NATIVE_DEPS) | $(BUILD_DIR)
	$(Q)echo "Building $(BIN_NAME)..."
	$(Q)$(ODIN) build . \
		-collection:generated="$(abspath $(GENERATED_DIR))" \
		$(ODIN_NATIVE_FLAGS) \
		-out:"$@"

$(NATIVE_LIBRARY): $(NATIVE_OBJECT)
	$(Q)$(AR) rcs "$@" "$<"

$(NATIVE_OBJECT): platform/native_menu/native_menu.m | $(NATIVE_DIR)
	$(Q)echo "Building native macOS menu bridge..."
	$(Q)MACOSX_DEPLOYMENT_TARGET="$(MACOSX_DEPLOYMENT_TARGET)" $(CLANG) -fobjc-arc -Wall -Wextra -c "$<" -o "$@"

$(GENERATED_LAYOUT): $(LAYOUT_SOURCE) tools/rgl_to_odin.py
	$(Q)echo "Generating Odin layout from $<..."
	$(Q)$(PYTHON) tools/rgl_to_odin.py "$<" "$@" --package layout

$(GENERATED_SETTINGS_LAYOUT): $(SETTINGS_LAYOUT_SOURCE) tools/rgl_to_odin.py
	$(Q)echo "Generating Odin settings layout from $<..."
	$(Q)$(PYTHON) tools/rgl_to_odin.py "$<" "$@" --package settings_layout

$(RESOURCE_STAMP): $(RESOURCE_SOURCES) | $(BUILD_DIR)
	$(Q)echo "Copying raygui resources..."
	$(Q)rm -rf "$(RESOURCE_BUILD_DIR)"
	$(Q)cp -R resources "$(RESOURCE_BUILD_DIR)"
	$(Q)touch "$@"

$(BUILD_DIR) $(NATIVE_DIR):
	$(Q)mkdir -p "$@"

# Open source resources in the raygui companion applications. Override the
# executable variables when the apps are not on PATH, for example:
# make layout-edit RGUI_LAYOUT=/Applications/rGuiLayout.app/Contents/MacOS/rGuiLayout
layout-edit:
	$(Q)command -v "$(RGUI_LAYOUT)" >/dev/null || { echo "rGuiLayout not found; set RGUI_LAYOUT=/path/to/executable" >&2; exit 1; }
	$(Q)"$(RGUI_LAYOUT)" "$(LAYOUT_SOURCE)"

settings-layout-edit:
	$(Q)command -v "$(RGUI_LAYOUT)" >/dev/null || { echo "rGuiLayout not found; set RGUI_LAYOUT=/path/to/executable" >&2; exit 1; }
	$(Q)"$(RGUI_LAYOUT)" "$(SETTINGS_LAYOUT_SOURCE)"

style-edit:
	$(Q)command -v "$(RGUI_STYLER)" >/dev/null || { echo "rGuiStyler not found; set RGUI_STYLER=/path/to/executable" >&2; exit 1; }
	$(Q)"$(RGUI_STYLER)" "$(STYLE_SOURCE)"

icons-edit:
	$(Q)command -v "$(RGUI_ICONS)" >/dev/null || { echo "rGuiIcons not found; set RGUI_ICONS=/path/to/executable" >&2; exit 1; }
	$(Q)"$(RGUI_ICONS)" "$(ICON_SOURCE)"

# Optional interoperability artifacts. The Odin application loads .rgs/.rgi
# directly and uses its generated Odin layout, so these C headers are not needed
# by the normal build.
export-raygui-code: | $(BUILD_DIR)
	$(Q)command -v "$(RGUI_LAYOUT)" >/dev/null || { echo "rGuiLayout not found" >&2; exit 1; }
	$(Q)command -v "$(RGUI_STYLER)" >/dev/null || { echo "rGuiStyler not found" >&2; exit 1; }
	$(Q)command -v "$(RGUI_ICONS)" >/dev/null || { echo "rGuiIcons not found" >&2; exit 1; }
	$(Q)mkdir -p "$(BUILD_DIR)/raygui-code"
	$(Q)"$(RGUI_LAYOUT)" --input "$(LAYOUT_SOURCE)" --output "$(BUILD_DIR)/raygui-code/layout.h"
	$(Q)"$(RGUI_LAYOUT)" --input "$(SETTINGS_LAYOUT_SOURCE)" --output "$(BUILD_DIR)/raygui-code/settings_layout.h"
	$(Q)"$(RGUI_STYLER)" --input "$(STYLE_SOURCE)" --output "$(BUILD_DIR)/raygui-code/style.h" --format 2
	$(Q)test -f "$(BUILD_DIR)/raygui-code/style.h.h" && mv "$(BUILD_DIR)/raygui-code/style.h.h" "$(BUILD_DIR)/raygui-code/style.h" || true
	$(Q)"$(RGUI_ICONS)" --input "$(ICON_SOURCE)" --output "$(BUILD_DIR)/raygui-code/icons.h"

clean:
	$(Q)rm -rf "$(BUILD_DIR)"
