#!/bin/bash

echo "1011"

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

# -----

export CFLAGS="-std=c++0x -O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd /tmp
wget -nc -q http://pkgs.fedoraproject.org/repo/pkgs/libvpx/libvpx-v1.3.0.tar.bz2/14783a148872f2d08629ff7c694eb31f/libvpx-v1.3.0.tar.bz2
rm -rf libvpx-v1.3.0
tar xf libvpx-v1.3.0.tar.bz2
cd libvpx-v1.3.0
./configure --help
time ./configure --log=yes --prefix=/tmp/dummy --disable-examples --disable-docs --enable-shared --disable-static \
 --disable-install-bins
cat config.log

quota -s
echo "FINISH"
exit
