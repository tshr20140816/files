#!/bin/bash

echo "1643"

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

# -----

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd /tmp

wget -nc -q https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tar.xz
tar xf Python-2.7.11.tar.xz
cd Python-2.7.11
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/python27 --disable-ipv6 --mandir=/tmp/gomi --docdir=/tmp/gomi
# time make -j4

cd /tmp
mkdir 20160518
cd 20160518
wget -nc -q ftp://ftp.xmlsoft.org/libxml2/libxml2-2.7.7-1.x86_64.rpm
rpm2cpio libxml2-2.7.7-1.x86_64.rpm | cpio -idmv
cd /tmp/20160518/usr/lib64
ln -s libxml2.so.2.7.7 libxml2.so 
cd /tmp/20160518
tree -a ./

cd /tmp
whereis XML2_CONFIG
export LD_LIBRARY_PATH=/tmp/20160518/usr/lib64
ls -lang /tmp/20160518/usr/lib64
wget -nc -q https://github.com/nghttp2/nghttp2/releases/download/v1.10.0/nghttp2-1.10.0.tar.xz
tar xf nghttp2-1.10.0.tar.xz
cd nghttp2-1.10.0
./configure --help
./configure

quota -s
echo "FINISH"
exit
