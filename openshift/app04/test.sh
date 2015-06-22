#!/bin/bash

export TZ=JST-9

echo "$(date)"

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

rm -rf libxml2-2.7.6*
rm -rf php-5.6.10*
rm -rf bison*
rm -rf re2c*

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

cd /tmp

[ -f autossh-1.4e.tgz ] || wget http://www.harding.motd.ca/autossh/autossh-1.4e.tgz

rm -rf autossh-1.4e
tar zxf autossh-1.4e.tgz

cd autossh-1.4e
./configure --help
