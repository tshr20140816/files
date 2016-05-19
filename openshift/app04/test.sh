#!/bin/bash

echo "1128"

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
rm -rf ccache-3.2.5 ccache gomi
rm -f ccache-3.2.5.tar.xz
rm -rf nghttp2-1.10.0
rm -rf Python-2.7.11
rm -rf 20160518
rm -f gcc-c++-5.3.1-6.fc23.i686.rpm

# -----

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd /tmp

rm -rf 20160519
mkdir 20160519
cd 20160519
wget -q -nc https://dl.fedoraproject.org/pub/fedora/linux/updates/23/x86_64/g/gcc-5.3.1-6.fc23.x86_64.rpm
ls -lang 
rpm2cpio gcc-5.3.1-6.fc23.x86_64.rpm | cpio -idmv

wget -q -nc https://dl.fedoraproject.org/pub/fedora/linux/updates/23/x86_64/g/glibc-2.22-16.fc23.x86_64.rpm
rpm2cpio glibc-2.22-16.fc23.x86_64.rpm | cpio -idmv

# export LD_LIBRARY_PATH=/tmp/20160519/lib64

# ./usr/bin/gcc --version
# ./usr/bin/gcc --help

# ldd ./usr/bin/gcc

./lib64/ld-linux-x86-64.so.2 --library-path /tmp/20160519/lib64:/tmp/20160519/usr/lib64 ./usr/bin/gcc --version
./lib64/ld-linux-x86-64.so.2 --library-path /tmp/20160519/lib64:/tmp/20160519/usr/lib64 ldd ./usr/bin/gcc

cd /tmp
wget -q -nc https://www.samba.org/ftp/ccache/ccache-3.2.5.tar.xz
rm -rf ccache-3.2.5
tar xf ccache-3.2.5.tar.xz
cd ccache-3.2.5
./configure
time make

quota -s
echo "FINISH"
exit
