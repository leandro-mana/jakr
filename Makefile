.PHONY: help build run test
.DEFAULT: help
.ONESHELL:
.SILENT:
SHELL=/bin/bash
.SHELLFLAGS = -ceo pipefail

# Default Keyword for test and run targets
KEYWORD=RELEASE-

# Image Tag
IMAGE_TAG=jakr-github-action

# Colours for Help Message and INFO formatting
YELLOW := "\e[1;33m"
NC := "\e[0m"
INFO := @bash -c 'printf $(YELLOW); echo "=> $$0"; printf $(NC)'
export 

help:
	$(INFO) "Run: make <target>"
	@echo -e "\n\tList of Supported Targets:"
	@echo
	@echo -e "\tbuild\t- Docker Build"
	@echo -e "\trun\t- [build] and docker run with KEYWORD: $(KEYWORD)"
	@echo -e "\ttest\t- Test entrypoint.sh with KEYWORD: $(KEYWORD)"

build:
	$(INFO) "Build Target"
	docker build --no-cache --tag $(IMAGE_TAG) --build-arg KEYWORD_ARG=$(KEYWORD) .
	$(INFO) "Docker Image Successfully Built, Tag:$(IMAGE_TAG)"

run: build
	$(INFO) "Build Target"
	docker run --rm $(IMAGE_TAG)

test:
	$(INFO) "Test Target"
	./entrypoint.sh $(KEYWORD)
