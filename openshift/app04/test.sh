#!/bin/bash

echo "0936"

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
rm -rf 20160425
rm -rf gomi

rm -rf ${OPENSHIFT_DATA_DIR}/usr

# -----

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd /tmp
mkdir 20160425
cd 20160425
wget -nc -q https://yum.gleez.com/6/x86_64/hhvm-3.5.0-4.el6.x86_64.rpm
rpm2cpio hhvm-3.5.0-4.el6.x86_64.rpm | cpio -idmv
tree -a ./

cat etc/hhvm/server.ini

quota -s
echo "FINISH"
exit
