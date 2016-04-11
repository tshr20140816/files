#!/bin/bash

echo "1700"

set -x

quota -s
oo-cgroup-read memory.failcnt

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

# tree -a ${OPENSHIFT_DATA_DIR}
# exit

/usr/bin/gear start --trace

shopt

cd /tmp

ls -lang

cd $OPENSHIFT_DATA_DIR

rm -rf test

tree -a $OPENSHIFT_DATA_DIR

mkdir test
cd test
wget -q https://yum.gleez.com/6/x86_64/hhvm-3.5.0-4.el6.x86_64.rpm
rpm2cpio hhvm-3.5.0-4.el6.x86_64.rpm | cpio -idmv

wget http://mirror.centos.org/centos/6/os/x86_64/Packages/boost-regex-1.41.0-27.el6.x86_64.rpm
rpm2cpio boost-regex-1.41.0-27.el6.x86_64.rpm | cpio -idmv

wget http://mirror.centos.org/centos/6/os/x86_64/Packages/libvpx-1.3.0-5.el6_5.x86_64.rpm
rpm2cpio libvpx-1.3.0-5.el6_5.x86_64.rpm | cpio -idmv

# wget http://mirror.centos.org/centos/6/os/x86_64/Packages/mysql-libs-5.1.73-5.el6_6.x86_64.rpm
# rpm2cpio mysql-libs-5.1.73-5.el6_6.x86_64.rpm | cpio -idmv

wget http://dl.fedoraproject.org/pub/epel/6/x86_64/inotify-tools-3.14-1.el6.x86_64.rpm
rpm2cpio inotify-tools-3.14-1.el6.x86_64.rpm | cpio -idmv

wget http://mirror.centos.org/centos/6/os/x86_64/Packages/boost-program-options-1.41.0-27.el6.x86_64.rpm
rpm2cpio boost-program-options-1.41.0-27.el6.x86_64.rpm | cpio -idmv

cd usr/lib64
ln -s libboost_regex.so.5 libboost_regex.so.1.54.0
ln -s libboost_program_options.so.5 libboost_program_options.so.1.54.0
ln -s /usr/lib64/mysql/libmysqlclient.so.16.0.0 libmysqlclient.so.18

cd $OPENSHIFT_DATA_DIR

tree test

export LD_LIBRARY_PATH=$OPENSHIFT_DATA_DIR/test/usr/lib:$OPENSHIFT_DATA_DIR/test/usr/lib/hhvm:$OPENSHIFT_DATA_DIR/test/usr/lib64
$OPENSHIFT_DATA_DIR/test/usr/bin/hhvm --version

# find / -name libinotifytools.so.* -print 2>/dev/null

ldd $OPENSHIFT_DATA_DIR/test/usr/bin/hhvm

echo "FINISH"
