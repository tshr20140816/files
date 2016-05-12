#!/bin/bash

echo "1418"

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
rm -rf ${OPENSHIFT_DATA_DIR}/local
rm -rf ${OPENSHIFT_DATA_DIR}/rpm
rm -rf ${OPENSHIFT_DATA_DIR}/usr
rm -rf 20160512

# -----

whereis nasm
whereis doxygen
whereis php-cli

ls -lang /var/lib/rpm

cd /tmp

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

mkdir 20160512
cd 20160512
wget -nc -q http://vault.centos.org/6.7/os/Source/SPackages/libvpx-1.3.0-5.el6_5.src.rpm
rpm2cpio libvpx-1.3.0-5.el6_5.src.rpm | cpio -idmv
ls -lang
cat libvpx.spec
rpmbuild --help
rm -rf ${OPENSHIFT_DATA_DIR}/rpm/SOURCES
mkdir -p ${OPENSHIFT_DATA_DIR}/rpm/SOURCES
# cp libvpx-v1.3.0.tar.bz2 ${OPENSHIFT_DATA_DIR}/rpm/SOURCES/
# cp *.patch ${OPENSHIFT_DATA_DIR}/rpm/SOURCES/
# export HOME=${OPENSHIFT_DATA_DIR}
# rpmbuild --dbpath ${OPENSHIFT_DATA_DIR} -bp libvpx.spec

wget -nc -q http://vault.centos.org/6.7/os/Source/SPackages/tbb-2.2-3.20090809.el6.src.rpm
rpm2cpio tbb-2.2-3.20090809.el6.src.rpm | cpio -idmv
ls -lang
cp *.tar.* ${OPENSHIFT_DATA_DIR}/rpm/SOURCES/
cp *.patch ${OPENSHIFT_DATA_DIR}/rpm/SOURCES/
export HOME=${OPENSHIFT_DATA_DIR}
rpmbuild --dbpath ${OPENSHIFT_DATA_DIR} -bp tbb.spec

quota -s
echo "FINISH"
exit
