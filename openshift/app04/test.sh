#!/bin/bash

echo "1048"

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

# shopt

cd /tmp

ls -lang

rm -rf $OPENSHIFT_DATA_DIR/boost
[ ! -f boost_1_54_0.tar.bz2 ] && wget http://heanet.dl.sourceforge.net/project/boost/boost/1.54.0/boost_1_54_0.tar.bz2
rm -rf boost_1_54_0
tar jxf boost_1_54_0.tar.bz2
ls -lang
cd boost_1_54_0
ls -lang
find ./ -name bootstrap.sh -print
./bootstrap.sh
./b2 --help
./b2 install -j4 --prefix=$OPENSHIFT_DATA_DIR/boost --without-chrono --without-graph

tree $OPENSHIFT_DATA_DIR/boost

cd $OPENSHIFT_DATA_DIR

rm -rf test

tree -a $OPENSHIFT_DATA_DIR

mkdir test
cd test
wget -q https://yum.gleez.com/6/x86_64/hhvm-3.5.0-4.el6.x86_64.rpm

wget http://mirror.centos.org/centos/6/os/x86_64/Packages/libvpx-1.3.0-5.el6_5.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/tbb-2.2-3.20090809.el6.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/oniguruma-5.9.1-3.1.el6.x86_64.rpm
# wget http://mirror.centos.org/centos/6/os/x86_64/Packages/boost-regex-1.41.0-27.el6.x86_64.rpm
# wget http://mirror.centos.org/centos/6/os/x86_64/Packages/boost-program-options-1.41.0-27.el6.x86_64.rpm
# wget http://mirror.centos.org/centos/6/os/x86_64/Packages/boost-filesystem-1.41.0-27.el6.x86_64.rpm
# wget http://mirror.centos.org/centos/6/os/x86_64/Packages/boost-thread-1.41.0-27.el6.x86_64.rpm
# wget http://mirror.centos.org/centos/6/os/x86_64/Packages/boost-system-1.41.0-27.el6.x86_64.rpm

wget http://dl.fedoraproject.org/pub/epel/6/x86_64/inotify-tools-3.14-1.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libdwarf-20140413-1.el6.x86_64.rpm
# wget http://dl.fedoraproject.org/pub/epel/6/x86_64/boost148-regex-1.48.0-7.el6.x86_64.rpm
# wget http://dl.fedoraproject.org/pub/epel/6/x86_64/boost148-program-options-1.48.0-7.el6.x86_64.rpm
# wget http://dl.fedoraproject.org/pub/epel/6/x86_64/boost148-filesystem-1.48.0-7.el6.x86_64.rpm
# wget http://dl.fedoraproject.org/pub/epel/6/x86_64/boost148-thread-1.48.0-7.el6.x86_64.rpm
# wget http://dl.fedoraproject.org/pub/epel/6/x86_64/boost148-system-1.48.0-7.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libwebp-0.4.3-3.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/lcms2-2.7-3.el6.x86_64.rpm
# wget http://pkgrepo.linuxtech.net/el6/release/x86_64/liblcms2-2.4-1.el6.x86_64.rpm

http://mirror.centos.org/centos/6/os/x86_64/Packages/gmp-4.3.1-7.el6_2.2.x86_64.rpm

find ./ -name "*.rpm" -print > list.txt

while read -r LINE
do
    rpm2cpio ${LINE} | cpio -idmv
done < list.txt

cd usr/lib64
ln -s libboost_regex.so.1.48.0 libboost_regex.so.1.54.0
ln -s libboost_program_options.so.1.48.0 libboost_program_options.so.1.54.0
ln -s libboost_thread-mt.so.1.48.0 libboost_thread.so.1.54.0
ln -s libboost_system.so.1.48.0 libboost_system.so.1.54.0
ln -s libboost_filesystem.so.1.48.0 libboost_filesystem.so.1.54.0
ln -s /usr/lib64/mysql/libmysqlclient.so.16.0.0 libmysqlclient.so.18
ln -s libwebp.so.5.0.3 libwebp.so.4

cd $OPENSHIFT_DATA_DIR

tree test

export LD_LIBRARY_PATH=$OPENSHIFT_DATA_DIR/test/usr/lib:$OPENSHIFT_DATA_DIR/test/usr/lib/hhvm:$OPENSHIFT_DATA_DIR/test/usr/lib64
$OPENSHIFT_DATA_DIR/test/usr/bin/hhvm --version

find / -name libboost_thread.so.* -print 2>/dev/null

ldd $OPENSHIFT_DATA_DIR/test/usr/bin/hhvm

echo "FINISH"
