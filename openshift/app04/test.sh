#!/bin/bash

echo "1335"

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
rm -rf ${OPENSHIFT_DATA_DIR}/local
rm -rf ${OPENSHIFT_DATA_DIR}/rpm
rm -rf ${OPENSHIFT_DATA_DIR}/usr
rm -rf 20160512

cd ${OPENSHIFT_DATA_DIR}
rm -f __db.* Name Packages Providename 
rm -rf rpm

# -----

cd /tmp

wget -q -nc https://github.com/fruux/Baikal/releases/download/0.4.4/baikal-0.4.4.zip
unzip baikal-0.4.4.zip
ls -lang
cd baikal*
cd Core/Frameworks/Baikal/Model/Config
cat Standard.php

quota -s
echo "FINISH"
exit
