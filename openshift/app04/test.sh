#!/bin/bash

echo "1526"

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

# -----

# -----

cd /tmp

if [ ! -f $OPENSHIFT_DATA_DIR/usr/lib/libboost_system.so.1.54.0 ]; then
wget -nc -q http://heanet.dl.sourceforge.net/project/boost/boost/1.54.0/boost_1_54_0.tar.bz2
rm -rf boost_1_54_0
tar jxf boost_1_54_0.tar.bz2

# export PATH="${OPENSHIFT_DATA_DIR}/local/bin:$PATH"
export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"
export HOME=${OPENSHIFT_DATA_DIR}
cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/user-config.jam
using gcc : : gcc : <cflags>"-O2 -march=native -fomit-frame-pointer -s -pipe" <cxxflags>"-O2 -march=native -fomit-frame-pointer -s -pipe" ;
__HEREDOC__

cd boost_1_54_0
./bootstrap.sh
./b2 --help
time ./b2 install -j1 --prefix=$OPENSHIFT_DATA_DIR/boost \
 --libdir=$OPENSHIFT_DATA_DIR/usr/lib \
 --link=shared \
 --runtime-link=shared \
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
 --without-wave

cd /tmp
rm -rf boost_1_54_0
rm -f boost_1_54_0.tar.bz2
rm -rf $OPENSHIFT_DATA_DIR/boost

tree -a $OPENSHIFT_DATA_DIR/usr/lib
# tree -a $OPENSHIFT_DATA_DIR/boost
fi
rm -rf $OPENSHIFT_DATA_DIR/boost

cd $OPENSHIFT_DATA_DIR

rm -f *.rpm

wget -nc -q https://yum.gleez.com/6/x86_64/hhvm-3.5.0-4.el6.x86_64.rpm

wget -nc -q http://mirror.centos.org/centos/6/os/x86_64/Packages/libvpx-1.3.0-5.el6_5.x86_64.rpm
wget -nc -q http://mirror.centos.org/centos/6/os/x86_64/Packages/tbb-2.2-3.20090809.el6.x86_64.rpm
wget -nc -q http://mirror.centos.org/centos/6/os/x86_64/Packages/oniguruma-5.9.1-3.1.el6.x86_64.rpm

wget -nc -q http://dl.fedoraproject.org/pub/epel/6/x86_64/inotify-tools-3.14-1.el6.x86_64.rpm
wget -nc -q http://dl.fedoraproject.org/pub/epel/6/x86_64/libdwarf-20140413-1.el6.x86_64.rpm
wget -nc -q http://dl.fedoraproject.org/pub/epel/6/x86_64/libwebp-0.4.3-3.el6.x86_64.rpm
wget -nc -q http://dl.fedoraproject.org/pub/epel/6/x86_64/lcms2-2.7-3.el6.x86_64.rpm

find ./ -name "*.rpm" -print > list.txt

while read -r LINE
do
    rpm2cpio ${LINE} | cpio -idmv
    rm -f ${LINE}
done < list.txt
rm -f list.txt

cd usr/lib64
ln -s /usr/lib64/mysql/libmysqlclient.so.16.0.0 libmysqlclient.so.18
ln -s libwebp.so.5.0.3 libwebp.so.4

rm -rf $OPENSHIFT_DATA_DIR/usr/share/doc/
rm -rf $OPENSHIFT_DATA_DIR/usr/share/man/
rm -rf $OPENSHIFT_DATA_DIR/usr/share/hhvm/LICENSE/

export LD_LIBRARY_PATH=$OPENSHIFT_DATA_DIR/usr/lib:$OPENSHIFT_DATA_DIR/usr/lib/hhvm:$OPENSHIFT_DATA_DIR/usr/lib64
$OPENSHIFT_DATA_DIR/usr/bin/hhvm --version

cat $OPENSHIFT_DATA_DIR/etc/hhvm/server.ini

tree -a $OPENSHIFT_DATA_DIR/usr/lib
tree -a $OPENSHIFT_DATA_DIR/usr/lib64

quota -s

cd /tmp
wget -nc -q https://www.pccc.com/downloads/apache/current/mod_fastcgi-current.tar.gz
rm -rf mod_fastcgi-2.4.6
tar zxf mod_fastcgi-current.tar.gz
cd mod_fastcgi-2.4.6
cp Makefile.AP2 Makefile
cat Makefile

echo "FINISH"
exit
