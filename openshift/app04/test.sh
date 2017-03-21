#!/bin/bash

echo "1441"

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

ls -lang ${OPENSHIFT_TMP_DIR}
ls -lang ${OPENSHIFT_DATA_DIR}
ls -lang ${OPENSHIFT_REPO_DIR}

quota -s

cd /tmp
rm -f binutils-2.20.51.0.2-5.44.el6.src.rpm
wget http://vault.centos.org/6.7/os/Source/SPackages/binutils-2.20.51.0.2-5.44.el6.src.rpm
rpm2cpio binutils-2.20.51.0.2-5.44.el6.src.rpm | cpio -idmv
tar zxf binutils-2.20.51.0.2-5.44.tar.gz
ls -lang

cd /tmp
rm -f master.zip
rm -rf distcc-master
# wget https://github.com/distcc/distcc/archive/master.zip
wget https://github.com/distcc/distcc/archive/distcc-3.1.zip
unzip distcc-3.1.zip
# ls -lang
cd distcc-distcc-3.1
./autogen.sh
./configure

quota -s
echo "FINISH"
exit
