#!/bin/bash

# 1414

set -x

cd /tmp

rm -rf gcc nss rpm*
rm -rf ${OPENSHIFT_DATA_DIR}/fuse

ls -lang

ls -lang ${OPENSHIFT_DATA_DIR}

quota -s
