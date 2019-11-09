ARG BASE_IMAGE_PREFIX
FROM ${BASE_IMAGE_PREFIX}alpine:latest

ARG ARCH
COPY qemu-${ARCH}-static /usr/bin

ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="Gregoire Pailler <gregoire@pailler.fr>" \
      org.label-schema.name="snifipv6" \
      org.label-schema.description="map IPv6 addresses to hostnames by listening Neighbor Solicitation messages " \
      org.label-schema.url="https://github.com/gpailler/snifipv6" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/gpailler/snifipv6"

VOLUME  [ "/data/in", "/data/out" ]
RUN apk add --no-cache tcpdump bash

COPY ipv6-to-hosts.sh /ipv6-to-hosts.sh

ENTRYPOINT /usr/sbin/tcpdump -i eth0 -e -n 'ip6[40]=135 and src host ::' -l | bash /ipv6-to-hosts.sh /data/in/leases_source /data/out
