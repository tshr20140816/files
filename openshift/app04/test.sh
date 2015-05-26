#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

cd /tmp

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
export HOME=${OPENSHIFT_DATA_DIR}

# rhc apps

cd $OPENSHIFT_DATA_DIR

ls -la .ssh

cat known_hosts
