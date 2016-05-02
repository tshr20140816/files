#!/bin/bash

echo "1548"

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
rm -rf gomi build
rm -rf ${OPENSHIFT_DATA_DIR}/usr

# -----

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd /tmp

mkdir 20160425
cd 20160425

# wget -nc -q http://mirror.centos.org/centos/6/os/x86_64/Packages/libvpx-1.3.0-5.el6_5.x86_64.rpm
# rpm2cpio libvpx-1.3.0-5.el6_5.x86_64.rpm | cpio -idmv

wget -nc -q http://vault.centos.org/6.7/os/Source/SPackages/libvpx-1.3.0-5.el6_5.src.rpm
rpm2cpio libvpx-1.3.0-5.el6_5.src.rpm | cpio -idmv

ls -lang

cat libvpx.spec

tar vf libvpx-v1.3.0.tar.bz2
# cd libvpx-v1.3.0
patch Bug-fix-in-ssse3-quantize-function.patch -p1 -b .patch0
patch x86inc-nasm.patch -p1 -b .x86inc-nasm
patch vp9-nasm.patch-p1 -b .vp9-nasm
patch sectalign-nasm.patch -p1 -b .sectalign-nasm

ls -lang

quota -s
echo "FINISH"
exit
