#!/bin/bash

# set -x

domain=*****
username=*****
password=*****

global_ip_file='/tmp/global_ip'
global_ip_old='0.0.0.0'

if [ -e ${global_ip_file} ]; then
  global_ip_old=(cat ${global_ip_file})
fi
global_ip_now=$(wget -qO - https://ieserver.net/ipcheck.shtml)

# echo ${global_ip_old}
# echo "\n"
# echo ${global_ip_now}

if [[ ${global_ip_now} =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  if [ ${global_ip_old} != ${global_ip_now} ]; then
    echo ${global_ip_now} > ${global_ip_file}
    wget -q --post-data="updatehost=1&password=${password}&domain=${domain}&username=${username}" \
     -O - https://ieserver.net/cgi-bin/dip.cgi
  fi
fi
