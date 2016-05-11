#!/bin/bash

echo "1304"

set -x

quota -s
oo-cgroup-read memory.failcnt
echo "$(oo-cgroup-read memory.usage_in_bytes)" | awk '{printf "%\047d\n", $0}'

# oo-cgroup-read all
# oo-cgroup-read report

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

/usr/bin/gear start --trace

cd /tmp
ls -lang
cd $OPENSHIFT_DATA_DIR
ls -lang

quota -s

# -----

cd /tmp
rm -f test.php
# wget -q https://github.com/tshr20140816/files/raw/master/openshift/app04/test.php
# cp test.php $OPENSHIFT_REPO_DIR/test.php

rm -rf 20160506
rm -rf 20160509
# rm -rf gomi build
# rm -rf ${OPENSHIFT_DATA_DIR}/usr

# -----

cd /tmp

mkdir ${OPENSHIFT_DATA_DIR}/test20160511 > /dev/null 2>&1
mkdir ${OPENSHIFT_DATA_DIR}/test20160511 > /dev/null 2>&1
rm -rf test20160511

wget -nc -q https://github.com/axboe/fio/archive/fio-2.9.tar.gz
tar xf fio-2.9.tar.gz
ls -lang
cd fio-2.9
./configure --help
cd /tmp
rm -f fio-2.9.tar.gz
rm -rf fio-2.9

quota -s
echo "FINISH"
exit
