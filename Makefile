config ?= release

PACKAGE := eohippus
GET_DEPENDENCIES_WITH := corral fetch
CLEAN_DEPENDENCIES_WITH := corral clean
COMPILE_WITH := corral run -- ponyc

BUILD_DIR ?= build/$(config)
SRC_DIR := $(PACKAGE)
TESTS_DIR := $(PACKAGE)/test
CLI_DIR := eohippus-cli
LSP_DIR := eohippus-lsp
FMT_DIR := eohippus-fmt
EXAMPLES_DIR := examples

binary := $(BUILD_DIR)/$(PACKAGE)
tests_binary := $(BUILD_DIR)/test
cli_binary := $(BUILD_DIR)/$(CLI_DIR)
lsp_binary := $(BUILD_DIR)/$(LSP_DIR)
fmt_binary := $(BUILD_DIR)/$(FMT_DIR)
docs_dir := build/$(PACKAGE)-docs

ifdef config
	ifeq (,$(filter $(config),debug release))
		$(error Unknown configuration "$(config)")
	endif
endif

ifeq ($(config),release)
	PONYC = $(COMPILE_WITH)
else
	PONYC = $(COMPILE_WITH) --debug
endif

ifneq ($(wildcard .git),)
  tag := $(shell cat VERSION)-$(shell git rev-parse --short HEAD)
else
  tag := $(shell cat VERSION)
endif

SOURCE_FILES := $(shell find $(SRC_DIR) -name *.pony)
CLI_FILES := $(shell find $(CLI_DIR) -name *.pony)
LSP_FILES := $(shell find $(LSP_DIR) -name *.pony)
FMT_FILES := $(shell find $(FMT_DIR) -name *.pony)
VERSION := "$(tag) [$(config)]"
GEN_FILES_IN := $(shell find $(SRC_DIR) -name \*.pony.in)
GEN_FILES = $(patsubst %.pony.in, %.pony, $(GEN_FILES_IN))

#EXAMPLES := $(notdir $(shell find $(EXAMPLES_DIR)/* -maxdepth 0 -type d))
#EXAMPLES_SOURCE_FILES := $(shell find $(EXAMPLES_DIR) -name *.pony)
#EXAMPLES_BINARIES := $(addprefix $(BUILD_DIR)/,$(EXAMPLES))

build: $(tests_binary)

test: unit-tests # build-examples

unit-tests: $(tests_binary)
	$^ --exclude=integration --sequential

cli: $(cli_binary)

lsp: $(lsp_binary)

fmt: $(fmt_binary)

$(binary): $(GEN_FILES) $(SOURCE_FILES) | $(BUILD_DIR)
	$(GET_DEPENDENCIES_WITH)
	$(PONYC) -o $(BUILD_DIR) $(SRC_DIR)

$(tests_binary): $(GEN_FILES) $(SOURCE_FILES) | $(BUILD_DIR)
	$(GET_DEPENDENCIES_WITH)
	$(PONYC) -o $(BUILD_DIR) $(TESTS_DIR)

$(cli_binary): $(GEN_FILES) $(SOURCE_FILES) $(CLI_FILES) | $(BUILD_DIR)
	$(GET_DEPENDENCIES_WITH)
	$(PONYC) -o $(BUILD_DIR) $(CLI_DIR)

$(lsp_binary): $(GEN_FILES) $(SOURCE_FILES) $(LSP_FILES) | $(BUILD_DIR)
	$(GET_DEPENDENCIES_WITH)
	$(PONYC) -o $(BUILD_DIR) $(LSP_DIR)

$(fmt_binary): $(GEN_FILES) $(SOURCE_FILES) $(FMT_FILES) | $(BUILD_DIR)
	$(GET_DEPENDENCIES_WITH)
	$(PONYC) -o $(BUILD_DIR) $(FMT_DIR)

%.pony: %.pony.in
	sed s/%%VERSION%%/$(VERSION)/ $< > $@

build-examples: $(EXAMPLES_BINARIES)

$(EXAMPLES_BINARIES): $(BUILD_DIR)/%: $(SOURCE_FILES) $(EXAMPLES_SOURCE_FILES) | $(BUILD_DIR)
	$(GET_DEPENDENCIES_WITH)
	$(PONYC) -o $(BUILD_DIR) $(EXAMPLES_DIR)/$*

clean:
	$(CLEAN_DEPENDENCIES_WITH)
	rm -rf $(BUILD_DIR)

$(docs_dir): $(SOURCE_FILES)
	$(GET_DEPENDENCIES_WITH)
	$(PONYC) --docs-public --pass=expr --output build $(SRC_DIR)

docs: $(docs_dir)

TAGS:
	ctags --recurse=yes $(SRC_DIR)

all: test

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: all build-examples clean TAGS test cli lsp fmt
