.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --no-builtin-rules --warn-undefined-variables

ifdef V
Q :=
else
Q := @
MAKEFLAGS += --no-print-directory
endif

.DEFAULT_GOAL := build

ODIN ?= odin
CC ?= cc
AR ?= ar
CURL ?= curl -L
TAR ?= tar
BUILD_DIR ?= build.nosync
BIN_NAME ?= bitspryte
BIN := $(BUILD_DIR)/$(BIN_NAME)
SOKOL_DIR ?= sokol
SOKOL_VERSION ?= master
SOKOL_URL ?= https://github.com/floooh/sokol-odin/archive/refs/heads/$(SOKOL_VERSION).tar.gz
SOKOL_STAMP := $(SOKOL_DIR)/.downloaded
PROFILE ?= debug

UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

ifeq ($(UNAME_S),Darwin)
  SOKOL_OS := macos
  SOKOL_BACKEND := metal
  SOKOL_DEFINE := SOKOL_METAL
  SOKOL_ARCH := $(if $(filter arm64,$(UNAME_M)),arm64,x64)
  CFLAGS_PLATFORM := -x objective-c -arch $(if $(filter arm64,$(UNAME_M)),arm64,x86_64)
  ODIN_ENV := PATH="$(dir $(shell xcrun -f clang)):$${PATH}"
else ifeq ($(UNAME_S),Linux)
  ifneq ($(UNAME_M),x86_64)
    $(error Linux currently requires x86_64)
  endif
  SOKOL_OS := linux
  SOKOL_BACKEND := gl
  SOKOL_DEFINE := SOKOL_GLCORE
  SOKOL_ARCH := x64
  CFLAGS_PLATFORM := -pthread
  ODIN_ENV :=
else
  $(error Unsupported platform: $(UNAME_S)/$(UNAME_M))
endif

ifeq ($(PROFILE),release)
  CFLAGS_PROFILE := -O2 -DNDEBUG
  ODIN_FLAGS := -o:speed -disable-assert
else
  CFLAGS_PROFILE := -g
  ODIN_FLAGS := -debug
endif

SOKOL_MODULES := app framebuffer gfx glue log
SOKOL_LIBS := $(foreach module,$(SOKOL_MODULES),$(SOKOL_DIR)/$(module)/sokol_$(module)_$(SOKOL_OS)_$(SOKOL_ARCH)_$(SOKOL_BACKEND)_$(PROFILE).a)
ODIN_SOURCES := $(shell find . -path './$(BUILD_DIR)' -prune -o -path './$(SOKOL_DIR)' -prune -o -name '*.odin' -print)

.PHONY: build run release check test deps clean help

build: $(BIN)

run: $(BIN)
	$(Q)"$(BIN)"

release:
	$(Q)$(MAKE) build PROFILE=release BIN="$(BUILD_DIR)/$(BIN_NAME)-release"

check: $(SOKOL_LIBS) | $(BUILD_DIR)
	$(Q)$(ODIN_ENV) $(ODIN) check . -debug

test: $(SOKOL_LIBS) | $(BUILD_DIR)
	$(Q)mkdir -p "$(BUILD_DIR)/tests"
	$(Q)$(ODIN_ENV) $(ODIN) test tests/actions -debug -out:"$(BUILD_DIR)/tests/actions"
	$(Q)$(ODIN_ENV) $(ODIN) test tests/drawing -debug -out:"$(BUILD_DIR)/tests/drawing"
	$(Q)$(ODIN_ENV) $(ODIN) test tests/checkerboard -debug -out:"$(BUILD_DIR)/tests/checkerboard"
	$(Q)$(ODIN_ENV) $(ODIN) test tests/canvas_view -debug -out:"$(BUILD_DIR)/tests/canvas_view"
	$(Q)$(ODIN_ENV) $(ODIN) test tests/layout -debug -out:"$(BUILD_DIR)/tests/layout"
	$(Q)$(ODIN_ENV) $(ODIN) test tests/events -debug -out:"$(BUILD_DIR)/tests/events"

deps: $(SOKOL_LIBS)

$(BIN): $(ODIN_SOURCES) $(SOKOL_LIBS) | $(BUILD_DIR)
	$(Q)echo "Building $(BIN_NAME) ($(PROFILE))"
	$(Q)$(ODIN_ENV) $(ODIN) build . $(ODIN_FLAGS) -out:"$@"

$(SOKOL_STAMP): | $(BUILD_DIR)
	$(Q)echo "Downloading sokol-odin ($(SOKOL_VERSION))"
	$(Q)tmp="$(BUILD_DIR)/sokol-download"; archive="$$tmp.tar.gz"; \
	rm -rf "$$tmp" "$$archive" "$(SOKOL_DIR)"; \
	mkdir -p "$$tmp"; \
	$(CURL) "$(SOKOL_URL)" -o "$$archive"; \
	$(TAR) -xzf "$$archive" -C "$$tmp"; \
	set -- "$$tmp"/*; \
	cp -R "$$1/sokol" "$(SOKOL_DIR)"; \
	touch "$@"; \
	rm -rf "$$tmp" "$$archive"

$(SOKOL_LIBS): $(SOKOL_STAMP)
	$(Q)module="$$(basename "$$(dirname "$@")")"; \
	echo "Compiling sokol_$$module ($(PROFILE))"; \
	obj="$(BUILD_DIR)/sokol_$$module.o"; \
	$(CC) $(CFLAGS_PLATFORM) $(CFLAGS_PROFILE) -DIMPL -D$(SOKOL_DEFINE) \
		-c "$(SOKOL_DIR)/c/sokol_$$module.c" -o "$$obj"; \
	$(AR) rcs "$@" "$$obj"; \
	rm -f "$$obj"

$(BUILD_DIR):
	$(Q)mkdir -p "$@"

clean:
	$(Q)rm -rf "$(BUILD_DIR)"

help:
	$(Q)printf '%s\n' \
		'Targets:' \
		'  build    Build a debug executable (default)' \
		'  run      Build and run' \
		'  release  Build an optimized executable' \
		'  check    Type-check the project' \
		'  test     Run application logic tests' \
		'  deps     Download and compile Sokol dependencies' \
		'  clean    Remove build output'
