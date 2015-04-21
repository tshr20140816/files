#!/bin/bash

echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

cd /tmp

# wget https://grafanarel.s3.amazonaws.com/builds/grafana-2.0.1.linux-x64.tar.gz
# tar xfz grafana-2.0.1.linux-x64.tar.gz

cd grafana-2.0.1
# ls -lang >> ${OPENSHIFT_LOG_DIR}/test.log 2>&1
tree >> ${OPENSHIFT_LOG_DIR}/test.log 2>&1

# cd /tmp
# ls -lang >> ${OPENSHIFT_LOG_DIR}/test.log 2>&1
