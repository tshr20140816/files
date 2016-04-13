#!/bin/bash

echo "0909"

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

rm -f cc*
rm -f jam*

ls -lang

rm -rf $OPENSHIFT_DATA_DIR/boost
[ ! -f boost_1_54_0.tar.bz2 ] && wget -q http://heanet.dl.sourceforge.net/project/boost/boost/1.54.0/boost_1_54_0.tar.bz2
rm -rf boost_1_54_0
tar jxf boost_1_54_0.tar.bz2
rm -f boost_1_54_0.tar.bz2
cd boost_1_54_0
# ls -lang
export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"
./bootstrap.sh
./b2 --help
time ./b2 install -j1 --prefix=$OPENSHIFT_DATA_DIR/boost \
 --libdir=$OPENSHIFT_DATA_DIR/usr/lib \
 --without-atomic \
 --without-chrono \
 --without-context \
 --without-coroutine \
 --without-date_time \
 --without-exception \
 --without-graph \
 --without-graph_parallel \
 --without-iostreams \
 --without-locale \
 --without-log \
 --without-math \
 --without-mpi \
 --without-python \
 --without-random \
 --without-serialization \
 --without-signals \
 --without-test \
 --without-timer \
 --without-wave \
 variant=release \
 link=shared \
 threading=multi \
 runtime-link=shared

tree $OPENSHIFT_DATA_DIR/boost

rm -rf /tmp/boost_1_54_0
rm -rf $OPENSHIFT_DATA_DIR/boost

cd $OPENSHIFT_DATA_DIR

wget -q https://yum.gleez.com/6/x86_64/hhvm-3.5.0-4.el6.x86_64.rpm

wget http://mirror.centos.org/centos/6/os/x86_64/Packages/libvpx-1.3.0-5.el6_5.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/tbb-2.2-3.20090809.el6.x86_64.rpm
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/oniguruma-5.9.1-3.1.el6.x86_64.rpm

wget http://dl.fedoraproject.org/pub/epel/6/x86_64/inotify-tools-3.14-1.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libdwarf-20140413-1.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libwebp-0.4.3-3.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/lcms2-2.7-3.el6.x86_64.rpm

find ./ -name "*.rpm" -print > list.txt

while read -r LINE
do
    rpm2cpio ${LINE} | cpio -idmv
    rm -f ${LINE}
done < list.txt

cd usr/lib64
ln -s /usr/lib64/mysql/libmysqlclient.so.16.0.0 libmysqlclient.so.18
ln -s libwebp.so.5.0.3 libwebp.so.4

rm -rf $OPENSHIFT_DATA_DIR/usr/share/doc/
rm -rf $OPENSHIFT_DATA_DIR/usr/share/man/
rm -rf $OPENSHIFT_DATA_DIR/usr/share/hhvm/LICENSE/
cd $OPENSHIFT_DATA_DIR

tree $OPENSHIFT_DATA_DIR

export LD_LIBRARY_PATH=$OPENSHIFT_DATA_DIR/usr/lib:$OPENSHIFT_DATA_DIR/usr/lib/hhvm:$OPENSHIFT_DATA_DIR/usr/lib64
$OPENSHIFT_DATA_DIR/usr/bin/hhvm --version

cat $OPENSHIFT_DATA_DIR/etc/hhvm/server.ini

quota -s

echo "FINISH"
