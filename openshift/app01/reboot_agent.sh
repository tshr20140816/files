#!/bin/bash

export TZ=JST-9

while:
do
    if [ -f ${OPENSHIFT_DATA_DIR}/install_check_point/install_all.ok ]; then
        exit
    fi
    if [ ! -f ${OPENSHIFT_DATA_DIR}/install_check_point/restart.txt ]; then
        sleep 10s
    else
        query_string="server=${OPENSHIFT_GEAR_DNS}&action=reboot"
        wget --spider $(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string} > /dev/null 2>&1
    
        /usr/bin/gear stop --trace
        /usr/bin/gear start --trace
        rm -f ${OPENSHIFT_DATA_DIR}/install_check_point/restart.txt
    fi
done;
