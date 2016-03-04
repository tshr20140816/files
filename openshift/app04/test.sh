#!/bin/bash

echo "0957"

# set -x

cd /tmp

ls -lang >> ${OPENSHIFT_LOG_DIR}/test.log

cd ${OPENSHIFT_DATA_DIR}

ls -lang >> ${OPENSHIFT_LOG_DIR}/test.log

exit
