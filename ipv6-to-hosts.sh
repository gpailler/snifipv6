#!/bin/bash

DNSMASQ_LEASES=$1
HOSTS_DIR=$2
WAIT=3

if !([ -p /dev/stdin ]); then
  echo "Only pipe input is supported"
  exit -1
fi

if !([ -r ${DNSMASQ_LEASES} ]); then
  echo "Source file ${DNSMASQ_LEASES} is not readable"
  exit -1
fi

mkdir -p ${HOSTS_DIR} > /dev/null 2>&1
if !([ -w ${HOSTS_DIR} ]); then
  echo "Output directory ${HOSTS_DIR} is not writeable"
  exit -1
fi

echo "Using source '${DNSMASQ_LEASES}' and output '${HOSTS_DIR}'"

while read LINE; do
  echo "Received packet: ${LINE}"
  echo "Wait ${WAIT}s to give a chance to have a registration in Dnsmasq leases file"
  sleep ${WAIT}

  MAC=$(echo $LINE | cut -d " " -f 2)
  IPV6=$(echo $LINE | cut -d " " -f 18 | sed 's/,$//')
  echo "Found MAC=${MAC} and IPv6=${IPV6}"

  if [[ ${IPV6} = fe80* ]]; then
    echo -e "Local link detected. Skip\n"
    continue
  fi

  HOSTNAME=$(grep -E "[0-9]+ $MAC" ${DNSMASQ_LEASES} | cut -d " " -f 4)
  if [ -z "${HOSTNAME}" ]; then
    echo -e "MAC not found in ${DNSMASQ_LEASES}. Skip\n"
    continue
  fi

  if [ "${HOSTNAME}" = "*" ]; then
    echo "Hostname '*' found in ${DNSMASQ_LEASES}. Skip\n"
    continue
  fi

  echo "Found matching hostname: ${HOSTNAME}"
  DATE=$(date --utc +%FT%TZ)
  LEASE_LINE="${IPV6} ${HOSTNAME}-6 # ${DATE}"
  LEASE_FILE="${HOSTNAME}-6_${IPV6}"
  LEASE_FULLPATH="${HOSTS_DIR}/${LEASE_FILE}"

  if [ -f "${LEASE_FULLPATH}" ]; then
    echo -e "Existing lease file '${LEASE_FULLPATH}'\n"
  else
    echo -e "Adding lease file '${LEASE_FULLPATH}'\n"
    echo ${LEASE_LINE} > ${LEASE_FULLPATH}
  fi
done
