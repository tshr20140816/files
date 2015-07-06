#!/bin/bash

export TZ=JST-9

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

set -x

cd /tmp

ls -lang

find ./php-5.6.10 -name '*' -type f | grep -e openshift 2>&1
