#!/bin/bash

echo "1118"

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
rm -f *.rpm
rm -f *.patch *.ver

# -----

export CFLAGS="-std=c++0x -O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd /tmp
mkdir 20160425
cd 20160425
wget -nc -q ftp://ftp.rediris.es/volumes/sites/linuxsoft.cern.ch/slc/updates/slc6X/SRPMS/tbb-2.2-3.20090809.el6.src.rpm
rpm2cpio tbb-2.2-3.20090809.el6.src.rpm | cpio -idmv
tree -a ./

quota -s
echo "FINISH"
exit
