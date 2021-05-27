FROM node:erbium-buster as build

RUN apt-get update \
  && apt-get install -y build-essential perl-modules

RUN deluser --remove-home node \
  && groupadd --gid 1000 nodered \
  && useradd --gid nodered --uid 1000 --shell /bin/bash --create-home nodered

RUN mkdir -p /data && chown 1000 /data

USER 1000
WORKDIR /data

COPY ./package.json /data/package.json
RUN npm install

COPY ./server.js /data/
COPY ./settings.js /data/
COPY ./.env /data/
COPY ./radarmap-flows.json /data/flows.json
COPY ./radarmap-flows_cred.json /data/flows_cred.json

## Release image
FROM node:erbium-buster-slim

RUN apt-get update && apt-get install -y perl-modules && apt-get install libzstd1 && rm -rf /var/lib/apt/lists/*

RUN deluser --remove-home node \
  && groupadd --gid 1000 nodered \
  && useradd --gid nodered --uid 1000 --shell /bin/bash --create-home nodered

RUN mkdir -p /data && chown 1000 /data

USER 1000

COPY --from=build /data /data

USER 0

RUN chgrp -R 0 /data \
  && chmod -R g=u /data

USER 1000

WORKDIR /data

ENV PORT 1880
ENV NODE_ENV=production
ENV NODE_PATH=/data/node_modules
#ENV TWCAPIKEY=
#ENV MAPBOXTOKEN=
EXPOSE 1880

CMD ["node", "/data/server.js", "/data/flows.json"]
