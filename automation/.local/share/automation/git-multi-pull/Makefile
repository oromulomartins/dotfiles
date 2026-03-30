SHELL := bash

BASE_DIR ?= .
SSH_KEY ?=
MAX_DEPTH ?= 10
FETCH_FIRST ?= true
INCLUDE_HIDDEN ?= false

SSH_KEY_ARG := $(if $(strip $(SSH_KEY)),--ssh-key "$(SSH_KEY)")
FETCH_ARG := $(if $(filter false,$(FETCH_FIRST)),--no-fetch,)
HIDDEN_ARG := $(if $(filter true,$(INCLUDE_HIDDEN)),--include-hidden,)

.PHONY: help pull-all dry-run

help:
	@echo "Available commands:"
	@echo "  make pull-all                     -> Update all Git repositories"
	@echo "  make dry-run                      -> Simulate the update without pulling"
	@echo ""
	@echo "Optional variables:"
	@echo "  BASE_DIR=/path                    -> Base directory to search"
	@echo "  SSH_KEY=/path/to/key              -> SSH key to add when needed"
	@echo "  MAX_DEPTH=10                      -> Maximum search depth"
	@echo "  FETCH_FIRST=true|false            -> Run fetch before pull"
	@echo "  INCLUDE_HIDDEN=true|false         -> Include hidden directories"
	@echo ""
	@echo "Examples:"
	@echo "  make pull-all BASE_DIR=~/workspace"
	@echo "  make dry-run BASE_DIR=~/workspace"
	@echo "  make pull-all BASE_DIR=~/workspace SSH_KEY=~/.ssh/id_ed25519"

pull-all:
	@bash ./scripts/git-pull-all.sh \
		--base-dir "$(BASE_DIR)" \
		--max-depth "$(MAX_DEPTH)" \
		$(SSH_KEY_ARG) \
		$(FETCH_ARG) \
		$(HIDDEN_ARG)

dry-run:
	@bash ./scripts/git-pull-all.sh \
		--base-dir "$(BASE_DIR)" \
		--max-depth "$(MAX_DEPTH)" \
		$(SSH_KEY_ARG) \
		$(FETCH_ARG) \
		$(HIDDEN_ARG) \
		--dry-run
