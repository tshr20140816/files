#!/bin/bash

echo "1038"

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

# tree -a ${OPENSHIFT_DATA_DIR}
# exit

/usr/bin/gear start --trace

ssh -help

# shopt

cd /tmp

ls -lang

echo "${0}"

exit

cd $OPENSHIFT_DATA_DIR

mkdir -p local/bin
cat << '__HEREDOC__' > local/bin/wrap_gcc
#!/bin/bash

set -x
time /usr/bin/gcc "$@"
__HEREDOC__
chmod +x ${OPENSHIFT_DATA_DIR}/local/bin/wrap_gcc
export PATH="${OPENSHIFT_DATA_DIR}/local/bin:$PATH"
export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"
export HOME=${OPENSHIFT_DATA_DIR}
cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/user-config.jam
using gcc : : wrap_gcc : <cflags>"-O2 -march=native -fomit-frame-pointer -s -pipe" <cxxflags>"-O2 -march=native -fomit-frame-pointer -s -pipe" ;
__HEREDOC__

rm -rf $OPENSHIFT_DATA_DIR/boost
[ ! -f boost_1_54_0.tar.bz2 ] && wget -q http://heanet.dl.sourceforge.net/project/boost/boost/1.54.0/boost_1_54_0.tar.bz2
rm -rf boost_1_54_0
tar jxf boost_1_54_0.tar.bz2
# rm -f boost_1_54_0.tar.bz2

wget https://github.com/tshr20140816/files/raw/master/openshift/app01/monitor_resourse.sh
bash monitor_resourse.sh &
pid=$!

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

kill ${pid}

rm -rf ${OPENSHIFT_DATA_DIR}/boost_1_54_0
quota -s

echo "FINISH"
exit

ls -lang $OPENSHIFT_DATA_DIR

wget -q http://www.accursoft.com/cartridges/network.tar.gz
wget -q http://www.accursoft.com/cartridges/yesod.tar.gz
wget -q http://www.accursoft.com/cartridges/snap.tar.gz
wget -q http://www.accursoft.com/cartridges/happstack.tar.gz
wget -q http://www.accursoft.com/cartridges/mflow.tar.gz
wget -q http://www.accursoft.com/cartridges/scotty.tar.gz

ls -lang

rm -f *.gz

quota -s

echo "FINISH"
