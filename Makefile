# Prevents one to use @ before each statement
ifndef VERBOSE
.SILENT:
endif

# DOCKER_REMOTE = defined in .env
-include .env

PROJECT_NAME = docker_stats_exporter
DOCKER_NAME = library/$(PROJECT_NAME)
DOCKER_VERSION := latest

.PHONY: help
help:
	printf '\033[32mUsage: make [target] ...\033[0m\n\nAvailable targets:\n\n'
	egrep -h '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

LINE := $(shell /usr/bin/bash -c "printf '%0.s⎯' {1..$(shell tput cols)}")

build: ## Build the production image
	printf "%s\n" $(LINE)
	echo "Building $(DOCKER_NAME) production image"
	printf "%s\n" $(LINE)
	DOCKER_BUILDKIT=1 docker build -t $(DOCKER_REMOTE)/$(DOCKER_NAME):$(DOCKER_VERSION) \
		-f Dockerfile .

push: ## Push the production image
	printf "%s\n" $(LINE)
	echo "Pushing $(DOCKER_NAME) production image"
	printf "%s\n" $(LINE)
	docker push $(DOCKER_REMOTE)/$(DOCKER_NAME):$(DOCKER_VERSION)

deploy: ## Deploy the production image
deploy: build push

check-updates: ## Check for package updates
	printf "%s\n" $(LINE)
	echo "Check $(PROJECT_NAME) package updates"
	printf "%s\n" $(LINE)
	ncu

install-updates: ## Update node packages and rebuild
	ncu -u && pnpm install
