#!/bin/bash

export TZ=JST-9

tail -n 10000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log.*
rm -f ${OPENSHIFT_LOG_DIR}/ccache.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
rm -f ${OPENSHIFT_TMP_DIR}/distcc_server_stderr_*
ls -d /tmp/cc* | grep -v ccache$ | xargs rm -f

set -x

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

cd /tmp

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

export LD=ld.gold
mkdir -p /tmp/local/bin
cp -f /tmp/ld.gold /tmp/local/bin/
# export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export PATH="/tmp/local/bin:$PATH"

cd /tmp

export HOME=${OPENSHIFT_DATA_DIR}
export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem

export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"

whereis rbenv
