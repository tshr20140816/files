#!/bin/bash

# echo "$(date)" >> ${OPENSHIFT_LOG_DIR}/test.log

cd /tmp

wget https://launchpad.net/pbzip2/1.1/1.1.12/+download/pbzip2-1.1.12.tar.gz >> ${OPENSHIFT_LOG_DIR}/test.log

cd pbzip2-1.1.12

ls >> ${OPENSHIFT_LOG_DIR}/test.log
