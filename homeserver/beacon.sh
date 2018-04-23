#!/bin/bash

loggly_token=dummy
mkdir /tmp/beacon

temperature=$(cat /sys/class/thermal/thermal_zone0/temp)
host_name=$(hostname)

curl -ivh -H 'content-type:text/plain' -d "${host_name} ${temperature}" \
 https://logs-01.loggly.com/inputs/${loggly_token}/tag/beacon/ > /tmp/beacon/$(date +"%H%M") 2>&1
