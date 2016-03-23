#!/bin/bash

echo "1010"

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

touch test.sh
cp -f test.sh test2.sh

echo "cmp 1"
cmp test.sh test2.sh

echo "cmp 2"
echo "AAA" >> test2.sh

cmp test.sh test2.sh

ls -lang

exit
