#!/bin/bash

loggly_token=*****
mkdir -p /tmp/beacon

log_file=/tmp/beacon/$(date +"%H%M")
temperature=$(cat /sys/class/thermal/thermal_zone0/temp)
host_name=$(hostname)

curl -ivh -H 'content-type:text/plain' -d "${host_name} ${temperature}" \
 https://logs-01.loggly.com/inputs/${loggly_token}/tag/beacon/ > ${log_file} 2>&1
