# Makefile

COMPOSE_FILE := build/docker-compose.yml
REGISTRY_USERNAME := techprober
REGISTRY := quay.io
IMAGE_NAME := nginx-http-flv-module
IMAGE_TAG := dev
DOMAIN_NAME := hikariai.net
ENV := prod
VERSION := latest

# Modify tagging mechanism
ifneq ($(VERSION), latest)
	export IMAGE_TAG=$(VERSION)
else
	export IMAGE_TAG=latest
endif

# List of commands
.PHONY: login
login:
	@echo "[INFO] Login to quay.io"
	@echo $(QUAY_PASS) | docker login $(REGISTRY) -u $(REGISTRY_USERNAME) --password-stdin

.PHONY: build
build:
	@echo "[INFO] Build application image with tag $(IMAGE_TAG)"
	@DOCKER_BUILDKIT=1 docker-compose \
		-f $(COMPOSE_FILE) \
		build

.PHONY: tag
tag:
	@echo "[INFO] Tag the local image as quay.io image"
	@docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(REGISTRY)/$(REGISTRY_USERNAME):$(IMAGE_TAG)
	@docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(REGISTRY)/$(REGISTRY_USERNAME):latest

.PHONY: publish
publish: login build tag
	@echo "[INFO] Publish application image with tag $(IMAGE_TAG) to $(REGISTRY)"
	@docker push $(IMAGE_NAME):$(IMAGE_TAG) $(REGISTRY)/$(REGISTRY_USERNAME):$(IMAGE_TAG)
	@docker push $(IMAGE_NAME):$(IMAGE_TAG) $(REGISTRY)/$(REGISTRY_USERNAME):latest

.PHONY: run
run:
	@echo "[INFO] Run application with tag $(IMAGE_TAG) to $(REGISTRY) locally"
	@docker-compose up -d

.PHONY: restart
restart:
	@echo "[INFO] Restart application with tag $(IMAGE_TAG) to $(REGISTRY) locally"
	@docker-compose up -d --force-recreate

.PHONY: help
help:
	$(info ${HELP_MESSAGE})
	@exit 0

define HELP_MESSAGE

Usage: $ make [TARGETS]

TARGETS

	help            Show the help menu
	login           Login to the target registry
	build           Build the application image
	tag             Tag the application image with a production tag to be pushed to the target registry
	publish         Build the application image, tag it with a custom version tag, and push it to the target registry (version required)
	run             Run the application container locally (VERSION optional)
	restart         Restart the application container instance (VERSION optional)

EXAMPLE USAGE

	build           Build the application image and tag it as latest
	publish         Build the application iamge, tag it as v1.0.1, and push it to the target registry
	run             Run the application container locally with the latest tag
	restart         Restart the application container with the latest tag, or a custom VERSION tag

endef
