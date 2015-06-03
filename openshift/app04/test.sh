#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

cd /tmp

find / -name ld.* -print 2>/dev/null

ls -lang

