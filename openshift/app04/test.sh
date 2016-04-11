#!/bin/bash

echo "1740"

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
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/boost-regex-1.41.0-27.el6.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/libvpx-1.3.0-5.el6_5.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/inotify-tools-3.14-1.el6.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/boost-program-options-1.41.0-27.el6.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/boost-filesystem-1.41.0-27.el6.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/tbb-2.2-3.20090809.el6.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/oniguruma-5.9.1-3.1.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libdwarf-20140413-1.el6.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/boost-thread-1.41.0-27.el6.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/boost-system-1.41.0-27.el6.x86_64.rpm
wget http://pkgrepo.linuxtech.net/el6/release/x86_64/liblcms2-2.4-1.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libwebp-0.4.3-3.el6.x86_64.rpm

find ./ -name "*.rpm" -print > list.txt

while read -r LINE
do
    rpm2cpio ${LINE} | cpio -idmv
done < list.txt

cd usr/lib64
ln -s libboost_regex.so.5 libboost_regex.so.1.54.0
ln -s libboost_program_options.so.5 libboost_program_options.so.1.54.0
ln -s libboost_thread_options.so.5 libboost_thread_options.so.1.54.0
ln -s libboost_system_options.so.5 libboost_system_options.so.1.54.0
ln -s libboost_filesystem.so.5 libboost_filesystem.so.1.54.0
ln -s /usr/lib64/mysql/libmysqlclient.so.16.0.0 libmysqlclient.so.18

cd $OPENSHIFT_DATA_DIR

tree test

export LD_LIBRARY_PATH=$OPENSHIFT_DATA_DIR/test/usr/lib:$OPENSHIFT_DATA_DIR/test/usr/lib/hhvm:$OPENSHIFT_DATA_DIR/test/usr/lib64
$OPENSHIFT_DATA_DIR/test/usr/bin/hhvm --version

# find / -name libinotifytools.so.* -print 2>/dev/null

ldd $OPENSHIFT_DATA_DIR/test/usr/bin/hhvm

echo "FINISH"
