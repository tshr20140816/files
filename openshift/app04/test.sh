#!/bin/bash

export TZ=JST-9

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

set -x

cd /tmp

ls -lang

tree php-5.6.10
