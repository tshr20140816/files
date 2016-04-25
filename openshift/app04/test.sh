#!/bin/bash

echo "1152"

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
rm -rf libvpx-v1.3.0
rm -f libvpx-v1.3.0.tar.bz2*

# -----

export CFLAGS="-std=c++0x -O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd /tmp
wget -nc -q ftp://bo.mirror.garr.it/2/scientific/6x/SRPMS/vendor/libvpx-1.3.0-5.el6_5.src.rpm
rpm2cpio libvpx-1.3.0-5.el6_5.src.rpm | cpio -idmv
tree -a ./

# cat *.patch

tar xf libvpx-v1.3.0.tar.bz2

patch < Bug-fix-in-ssse3-quantize-function.patch

# cd libvpx-v1.3.0
# ./configure --help
# ./configure

quota -s
echo "FINISH"
exit
