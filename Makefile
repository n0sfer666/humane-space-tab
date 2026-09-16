SHELL := /bin/bash

TAG := $(shell git describe --tags --abbrev=0 2>/dev/null)
VERSION ?= $(TAG:v%=%)
BUILD ?= $(shell git rev-list --count $(TAG)..HEAD 2>/dev/null)

.DEFAULT_GOAL := help
.PHONY: help dev install test lint build

help:
	@echo "Humane Space Tab — $(if $(VERSION),$(VERSION) ($(BUILD)),no v* tag, pass VERSION=)"
	@echo
	@echo "  make dev        build Debug and run it from .build; /Applications is left alone"
	@echo "  make install    package, install into /Applications, relaunch"
	@echo "  make test       swift test"
	@echo "  make lint       swiftlint and swift format, both strict"
	@echo "  make build      swift build --build-tests"
	@echo
	@echo "  VERSION and BUILD come from the latest v* tag and the commits since it."
	@echo "  Override them: make install VERSION=0.3.0 BUILD=7"

dev: version
	@scripts/dev.sh "$(VERSION)" "$(BUILD)"

install: version
	@scripts/install.sh "$(VERSION)" "$(BUILD)"

test:
	swift test

lint:
	swiftlint lint --quiet --strict
	swift format lint --recursive --strict Sources Tests Package.swift

build:
	swift build --build-tests

.PHONY: version
version:
	@[[ -n "$(VERSION)" ]] || { \
	    echo "error: no v* tag to read a version from — pass one, as in 'make $(MAKECMDGOALS) VERSION=0.3.0'" >&2; \
	    exit 1; \
	}
