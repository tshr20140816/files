#!/bin/bash

echo "1525"

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

ls -lang

rm -rf ghc*

cd $OPENSHIFT_DATA_DIR

rmdir -rf haskell
rm -rf .cabal
rm -rf .ghc

rm -rf test
mkdir test
cd test
wget https://yum.gleez.com/6/x86_64/hhvm-3.5.0-4.el6.x86_64.rpm

rpm2cpio glibc-devel-2.12-1.166.el6.i686.rpm | cpio -idmv

cd ../

tree test

echo "FINISH"
