#!/bin/bash

echo "1115"

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

# -----

rm -f jam*

# -----

cd /tmp

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

tree -a $OPENSHIFT_DATA_DIR/usr/lib
tree -a $OPENSHIFT_DATA_DIR/boost

quota -s

echo "FINISH"
exit
