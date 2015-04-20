#!/bin/bash

echo "$(date)" >> ${OPENSHIFT_LOG_DIR}/test.log

cd /tmp

rm -f pbzip2-1.1.12.tar.gz
wget https://launchpad.net/pbzip2/1.1/1.1.12/+download/pbzip2-1.1.12.tar.gz >> ${OPENSHIFT_LOG_DIR}/test.log

tar xvz pbzip2-1.1.12.tar.gz

cd pbzip2-1.1.12

time make -j4 >> ${OPENSHIFT_LOG_DIR}/test.log

ls -lang >> ${OPENSHIFT_LOG_DIR}/test.log
