#!/bin/bash

echo "1347"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang

# wget --help

# curl --help

rm -f ShellCheck-0.2.0-2.fc19.x86_64.rpm

echo "START $(date +%Y/%m/%d" "%H:%M:%S)"

# curl -LI http://olea.org/paquetes-rpm/fedora-19/ShellCheck-0.2.0-2.fc19.x86_64.rpm
wget http://olea.org/paquetes-rpm/fedora-19/ShellCheck-0.2.0-2.fc19.x86_64.rpm

rpm2cpio ShellCheck-0.2.0-2.fc19.x86_64.rpm | cpio --list
rpm2cpio ShellCheck-0.2.0-2.fc19.x86_64.rpm | cpio -idmv

tree ./

echo "FINISH $(date +%Y/%m/%d" "%H:%M:%S)"

ls -lang

exit
