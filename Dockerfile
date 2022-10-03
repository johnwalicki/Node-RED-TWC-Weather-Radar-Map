FROM registry.access.redhat.com/ubi9:9.0.0-1640 as build
LABEL stage=builder

RUN dnf install --nodocs -y nodejs nodejs-nodemon npm --setopt=install_weak_deps=0 --disableplugin=subscription-manager \
    && dnf install --nodocs -y make git gcc gcc-c++  --setopt=install_weak_deps=0 --disableplugin=subscription-manager \
    && dnf clean all --disableplugin=subscription-manager

RUN mkdir -p /opt/app-root/data
WORKDIR /opt/app-root/data
COPY ./package.json /opt/app-root/data/package.json
# Prevent "npm ERR! code ERR_SOCKET_TIMEOUT" by upgrading from npm 8.3 to >= npm 8.5.1
RUN npm install --no-audit --no-update-notifier --no-fund --omit=dev --omit=optional --location=global npm@8.19.2
RUN npm install --no-audit --no-update-notifier --no-fund --omit=dev

RUN rm -rf /opt/app-root/data/node_modules/image-q/demo
COPY ./settings.js /opt/app-root/data/
# COPY ./.env /opt/app-root/data/
COPY ./radarmap-flows.json /opt/app-root/data/flows.json
COPY ./radarmap-flows_cred.json /opt/app-root/data/flows_cred.json

## Release image
# FROM registry.access.redhat.com/ubi9/nodejs-16-minimal:1-60
FROM registry.access.redhat.com/ubi9/ubi-minimal:9.0.0-1644

USER 0
RUN microdnf update -y --nodocs && \
    microdnf install --nodocs -y nodejs nodejs-nodemon npm --setopt=install_weak_deps=0 && \
    microdnf clean all && \
    rm -rf /mnt/rootfs/var/cache/* /mnt/rootfs/var/log/dnf* /mnt/rootfs/var/log/yum.*

RUN mkdir -p /opt/app-root/data && chown 1000 /opt/app-root/data
USER 1000
COPY --from=build /opt/app-root/data /opt/app-root/data/
WORKDIR /opt/app-root/data

ENV PORT 1880
ENV NODE_ENV=production
ENV NODE_PATH=/opt/app-root/data/node_modules
#ENV TWCAPIKEY=
#ENV MAPBOXTOKEN=
EXPOSE 1880

CMD ["node", "/opt/app-root/data/node_modules/node-red/red.js", "--setting", "/opt/app-root/data/settings.js", "/opt/app-root/data/flows.json"]
