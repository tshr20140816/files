#!/bin/bash

echo "1603"

set -x

quota -s
oo-cgroup-read memory.failcnt

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

# tree -a ${OPENSHIFT_DATA_DIR}
# exit

/usr/bin/gear start --trace

shopt

cd /tmp

rm -rf ShellCheck-0.4.3
rm -f ShellCheck-0.4.3*
rm -f regex.log
rm -f monitor_resourse.sh

ls -lang

cd $OPENSHIFT_DATA_DIR

rm -rf test

tree -a $OPENSHIFT_DATA_DIR

mkdir test
cd test
wget https://yum.gleez.com/6/x86_64/hhvm-3.5.0-4.el6.x86_64.rpm

rpm2cpio hhvm-3.5.0-4.el6.x86_64.rpm | cpio -idmv

cd ../

tree test

export LD_LIBRARY_PATH=$OPENSHIFT_DATA_DIR/test/usr/lib
$OPENSHIFT_DATA_DIR/test/usr/bin/hhvm --version

whereis cmake

cmake --version

echo "FINISH"
