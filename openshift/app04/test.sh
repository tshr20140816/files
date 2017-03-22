#!/bin/bash

echo "1058"

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

# cd /tmp
# rm -f ./ *
# rm -rf binutils-2.20.51.0.2
# wget http://mirror.centos.org/centos/6/os/x86_64/Packages/binutils-devel-2.20.51.0.2-5.44.el6.x86_64.rpm
# rpm2cpio binutils-devel-2.20.51.0.2-5.44.el6.x86_64.rpm | cpio -idmv
# ls -lang

cd /tmp
rm -f master.zip
rm -rf distcc-master
wget https://github.com/distcc/distcc/archive/master.zip
unzip master.zip
cd distcc-master
./autogen.sh
./configure --help
./configure --without-libiberty --infodir=/tmp/ --mandir=/tmp/ --docdir=/tmp/

cat survey.txt

# rm -f distcc-3.1.zip
# rm -rf distcc-distcc-3.1
# wget https://github.com/distcc/distcc/archive/distcc-3.1.zip
# unzip distcc-3.1.zip
# ls -lang
# cd distcc-distcc-3.1
# ./autogen.sh
# ./configure --prefix=${OPENSHIFT_DATA_DIR}/distcc
# time make -j4

quota -s
echo "FINISH"
exit
