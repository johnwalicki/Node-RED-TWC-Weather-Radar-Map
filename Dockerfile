FROM registry.access.redhat.com/ubi8/nodejs-14-minimal:latest as build

RUN mkdir -p /opt/app-root/data
WORKDIR /opt/app-root/data
COPY ./package.json /opt/app-root/data/package.json
RUN npm install --only=prod

COPY ./server.js /opt/app-root/data/
COPY ./settings.js /opt/app-root/data/
COPY ./.env /opt/app-root/data/
COPY ./radarmap-flows.json /opt/app-root/data/flows.json
COPY ./radarmap-flows_cred.json /opt/app-root/data/flows_cred.json

## Release image
FROM registry.access.redhat.com/ubi8/nodejs-14-minimal:latest

USER 0

RUN microdnf update -y --nodocs && \
    microdnf install --nodocs -y shadow-utils && \
    microdnf clean all

RUN groupadd --gid 1001 nodered \
  && useradd --gid nodered --uid 1001 --shell /bin/bash --create-home nodered

RUN mkdir -p /opt/app-root/data && chown 1001 /opt/app-root/data

USER 1001

COPY --from=build /opt/app-root/data /opt/app-root/data/

USER 0

RUN chgrp -R 0 /opt/app-root/data \
  && chmod -R g=u /opt/app-root/data

USER 1001

WORKDIR /opt/app-root/data

ENV PORT 1880
ENV NODE_ENV=production
ENV NODE_PATH=/data/node_modules
#ENV TWCAPIKEY=
#ENV MAPBOXTOKEN=
EXPOSE 1880

CMD ["node", "/opt/app-root/data/server.js", "/opt/app-root/data/flows.json"]
