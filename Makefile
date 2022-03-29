# Makefile for Node-RED-TWC-Weather-Radar-Map

DOCKERHUB_ID:=walicki
ICR_ID=us.icr.io/devnation-walicki
IMG_NAME:="node-red-twc-weather-radar-map"
IMG_VERSION:="2.1"
ARCH:="amd64"

# Store the secrets in a .env file  (see ./.env.example)
# or modify the Makefile "run" rule below to run the
#   docker container with -e environment variables
# or store them directly in the Dockerfile
TWCAPIKEY:=
MAPBOXTOKEN:=flow now uses ESRI tiles instead of MapBox

# Leave blank for open DockerHub containers
# CONTAINER_CREDS:=-r "registry.wherever.com:myid:mypw"
CONTAINER_CREDS:=-r "us.icr.io:iamapikey:<removed for demo>"

default: build run

# Examples of container images built using different techniques
ubi8-onestage:
	echo podman build --rm -t $(ICR_ID)/$(IMG_NAME)-ubi8-onestage:$(IMG_VERSION) -f Dockerfile.ubi8.onestage
	podman build --rm -t $(ICR_ID)/$(IMG_NAME)-ubi8-onestage:$(IMG_VERSION) -f Dockerfile.ubi8.onestage

ubi8-twostage:
	echo podman build --rm -t $(ICR_ID)/$(IMG_NAME)-ubi8:$(IMG_VERSION) -f Dockerfile.ubi8
	podman build --rm -t $(ICR_ID)/$(IMG_NAME)-ubi8:$(IMG_VERSION) -f Dockerfile.ubi8
	podman image prune --filter label=stage=builder --force

minimal:
	echo podman build --rm -t $(ICR_ID)/$(IMG_NAME)-ubiminimal:$(IMG_VERSION) -f Dockerfile.ubi8minimal
	podman build --rm -t $(ICR_ID)/$(IMG_NAME)-ubiminimal:$(IMG_VERSION) -f Dockerfile.ubi8minimal
	podman image prune --filter label=stage=builder --force

build:
	echo podman build --rm -t $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) .
	podman build --rm -t $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) .
	podman image prune --filter label=stage=builder --force

dev: stop build
	podman run -it --name ${IMG_NAME} \
          $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) /bin/bash

run: stop
	podman run -d \
          --name ${IMG_NAME} \
          --env-file secrets/env.list \
          -p 1880:1880 \
          --restart unless-stopped \
          $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION)

test:
	xdg-open http://127.0.0.1:1880

ui:
	xdg-open http://127.0.0.1:1880/ui

push:
	podman push $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION)

push-icr:
	podman tag $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION)
	podman push $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION)

stop:
	@podman rm -f ${IMG_NAME} >/dev/null 2>&1 || :

clean:
	@podman rmi -f $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) >/dev/null 2>&1 || :

login:
	ibmcloud login --sso
	ibmcloud cr login
	ibmcloud cr region-set us-south
	ibmcloud target -g Default

code-engine:
	ibmcloud ce project list
	ibmcloud ce project select -n walicki-code-engine
	ibmcloud ce application list
	ibmcloud ce application get -n node-red-twc-weather-maps
	ibmcloud ce configmap create --name twc-secrets --from-env-file secrets/env.list
	ibmcloud ce app update --name node-red-twc-weather-maps --image $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) --port 1880 --max-scale 1 --cpu 0.25 --memory 0.5G --env-from-configmap twc-secrets
	# ibmcloud ce app create --name node-red-twc-weather-maps --image $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) --port 1880 --max-scale 1 --cpu 0.25 --memory 0.5G --env TWCAPIKEY=twckey --env-from-configmap twc-secrets
	ibmcloud ce app logs --name node-red-twc-weather-maps

multiarch:
	echo podman build --arch arm64 -t $(ICR_ID)/$(IMG_NAME)-arm64:$(IMG_VERSION) -f Dockerfile
	podman build --arch arm64 -t $(ICR_ID)/$(IMG_NAME)-arm64:$(IMG_VERSION) -f Dockerfile
	podman image prune --filter label=stage=builder --force

.PHONY: build dev run push test ui stop clean
