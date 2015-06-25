#!/bin/bash

# 1507

export TZ=JST-9

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

set -x

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}
