#!/bin/bash

echo "1041"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang

rm -rf ./usr
rm -rf ./etc
rm -rf ./lib64
rm -rf ./sbin
rm -rf ./var

rm -f *.rpm

wget http://olea.org/paquetes-rpm/fedora-19/ShellCheck-0.2.0-2.fc19.src.rpm

rpm2cpio ShellCheck-0.2.0-2.fc19.src.rpm | cpio -idmv

tree ./

quota -s

exit
