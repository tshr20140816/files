#!/bin/bash

echo "1450"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

export GNUPGHOME=${OPENSHIFT_DATA_DIR}/.gnupg
rm -rf ${GNUPGHOME}

cd /tmp

ls -lang

rm -f parallel-latest.tar.bz2.sig
rm -f parallel-latest.tar.bz2
rm -f super_pi-jp.tar.gz

wget --passive-ftp ftp://pi.super-computing.org/Linux_jp/super_pi-jp.tar.gz

ls -lang

exit
