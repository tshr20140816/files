#!/bin/bash

echo "1352"

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
rm -rf 20160422
rm -rf 20160423
rm -rf 20160424
rm -rf 20160425
rm -rf gomi

rm -rf ${OPENSHIFT_DATA_DIR}/usr

# -----

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd /tmp
mkdir 20160425
cd 20160425
wget -nc -q ftp://ftp.ntua.gr/pub/linux/fedora-epel/6/SRPMS/inotify-tools-3.14-1.el6.src.rpm
rpm2cpio inotify-tools-3.14-1.el6.src.rpm | cpio -idmv
tree -a ./
tar xf inotify-tools-3.14.tar.gz
cd inotify-tools-3.14
./configure --help
time ./configure --prefix=/tmp/gomi --libdir=${OPENSHIFT_DATA_DIR}/usr/lib --enable-static=no
time make -j4
make install
tree -a ${OPENSHIFT_DATA_DIR}/usr/lib

cd /tmp
mkdir 20160424
cd 20160424
wget -nc -q http://vault.centos.org/6.7/os/Source/SPackages/oniguruma-5.9.1-3.1.el6.src.rpm
rpm2cpio oniguruma-5.9.1-3.1.el6.src.rpm | cpio -idmv
tree -a ./
tar xf onig-5.9.1.tar.gz
cd onig-5.9.1
./configure --help
time ./configure --prefix=/tmp/gomi --libdir=${OPENSHIFT_DATA_DIR}/usr/lib
time make -j4
make install
tree -a ${OPENSHIFT_DATA_DIR}/usr/lib

cd /tmp
mkdir 20160423
wget -nc -q http://download.fedoraproject.org/pub/epel/6/SRPMS/libdwarf-20140413-1.el6.src.rpm
rpm2cpio libdwarf-20140413-1.el6.src.rpm | cpio -idmv
ls -lang

cd /tmp
mkdir 20160422
wget -nc -q ftp://ftp.ntua.gr/pub/linux/fedora-epel/6/SRPMS/libwebp-0.4.3-3.el6.src.rpm
rpm2cpio libwebp-0.4.3-3.el6.src.rpm | cpio -idmv
ls -lang

quota -s
echo "FINISH"
exit
