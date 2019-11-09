# snifipv6
[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/gpailler/snifipv6)](https://hub.docker.com/r/gpailler/snifipv6/builds)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/gpailler/snifipv6)](https://hub.docker.com/r/gpailler/snifipv6/builds)
[![Docker Pulls](https://img.shields.io/docker/pulls/gpailler/snifipv6.svg)](https://hub.docker.com/r/gpailler/snifipv6/)
[![](https://images.microbadger.com/badges/version/gpailler/snifipv6:latest.svg)](https://microbadger.com/images/gpailler/snifipv6:latest)
[![](https://images.microbadger.com/badges/image/gpailler/snifipv6:latest.svg)](https://microbadger.com/images/gpailler/snifipv6:latest)

snifIPv6 is a simple script to map IPv6 addresses to hostnames by listening Neighbor Solicitation messages

Check https://gpailler.github.io/2019-10-13-pi4-part4/ for details

Usage
```
$ docker run -d \
             -v ${PWD}/hosts/:/data/out/ \
             -v /var/lib/misc/dnsmasq.leases:/data/in/leases_source:ro \
             --net=host \
             gpailler/snifipv6
```

Using Compose
```
version: "3"

services:
  snifipv6:
    container_name: snifipv6
    image: gpailler/snifipv6:latest
    volumes:
      - ./hosts/:/data/out/
      - /var/lib/misc/dnsmasq.leases:/data/in/leases_source:ro
    network_mode: host
    restart: unless-stopped
```

Dnsmasq configuration
```
$ echo "hostsdir=${PWD}/hosts" | sudo tee -a /etc/dnsmasq.d/ipv6-hostdir.conf
$ sudo systemctl restart dnsmasq
```

Cron task executed once a month to remove files older than 30 days
```
4 4 1 * * sudo find [FULLPATH_TO_HOSTS_FOLDER]/* -mtime +30 -delete && sudo systemctl restart dnsmasq
```
