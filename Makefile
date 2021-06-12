# Makefile for Node-RED-TWC-Weather-Radar-Map

DOCKERHUB_ID:=
IMG_NAME:="node-red-twc-weather-radar-map"
IMG_VERSION:="1.0.0"
ARCH:="amd64"

# Store the secrets in a .env file  (see ./.env.example)
# or modify the Makefile "run" rule below to run the
#   docker container with -e environment variables
# or store them directly in the Dockerfile
TWCAPIKEY:=
MAPBOXTOKEN:=

# Leave blank for open DockerHub containers
# CONTAINER_CREDS:=-r "registry.wherever.com:myid:mypw"
CONTAINER_CREDS:=

default: build run

build:
	docker build --rm -t $(DOCKERHUB_ID)/$(IMG_NAME):$(IMG_VERSION) .
	docker image prune --filter label=stage=builder --force

dev: stop build
	docker run -it --name ${IMG_NAME} \
          $(DOCKERHUB_ID)/$(IMG_NAME):$(IMG_VERSION) /bin/bash

run: stop
	docker run -d \
          --name ${IMG_NAME} \
          --env-file .env \
          -p 1880:1880 \
          --restart unless-stopped \
          $(DOCKERHUB_ID)/$(IMG_NAME):$(IMG_VERSION)

test:
	xdg-open http://127.0.0.1:1880

ui:
	xdg-open http://127.0.0.1:1880/ui

push:
	docker push $(DOCKERHUB_ID)/$(IMG_NAME):$(IMG_VERSION)

stop:
	@docker rm -f ${IMG_NAME} >/dev/null 2>&1 || :

clean:
	@docker rmi -f $(DOCKERHUB_ID)/$(IMG_NAME):$(IMG_VERSION) >/dev/null 2>&1 || :

.PHONY: build dev run push test ui stop clean
