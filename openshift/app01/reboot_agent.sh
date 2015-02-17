#!/bin/bash

export TZ=JST-9

while:
do
    if [ ! -f ${OPENSHIFT_DATA_DIR}/install_check_point/restart.txt ]; then
        sleep 10s
    else
        /usr/bin/gear stop --trace
        /usr/bin/gear start --trace
    fi
done;
