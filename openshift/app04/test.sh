#!/bin/bash

echo "1518"

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
rm -rf 20160523
rm -f gcc-c++-5.3.1-6.fc23.i686.rpm
rm -f *.patch
rm -f *.bz2
rm -rf gcc*

cd $OPENSHIFT_DATA_DIR
rm -rf bin include lib lib64 libexec local sbin share usr
ls -lang

# -----

# convert --help

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd /tmp

mkdir 20160523
cd 20160523
wget -q -nc http://mirrors.concertpass.com/gcc/releases/gcc-4.4.7/gcc-core-4.4.7.tar.bz2
tar xf gcc-core-4.4.7.tar.bz2
ls -lang
cd gcc*
./configure
# time make -j2

find / -name libmpc.so.2 -print 2>/dev/null

quota -s
echo "FINISH"
exit
