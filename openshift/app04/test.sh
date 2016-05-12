#!/bin/bash

echo "0933"

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

# -----

cd /tmp

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

rm -f gmp-6.1.0.tar.lz
wget -nc -q https://gmplib.org/download/gmp/gmp-6.1.0.tar.xz
tar xf gmp-6.1.0.tar.xz
ls -lang
cd gmp-6.1.0
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/local --enable-static=no --libdir=${OPENSHIFT_DATA_DIR}/usr/lib
time make -j4
make install
cd /tmp
rm -rf gmp-6.1.0
rm -f gmp-6.1.0.tar.xz
tree ${OPENSHIFT_DATA_DIR}

file ${OPENSHIFT_DATA_DIR}/usr/lib/libgmp.so.10.3.0
strip -d ${OPENSHIFT_DATA_DIR}/usr/lib/libgmp.so.10.3.0
file ${OPENSHIFT_DATA_DIR}/usr/lib/libgmp.so.10.3.0

quota -s
echo "FINISH"
exit
