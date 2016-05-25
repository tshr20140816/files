#!/bin/bash

echo "1649"

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
ls -lang $OPENSHIFT_REPO_DIR

cat $OPENSHIFT_REPO_DIR/test.php
cat $OPENSHIFT_REPO_DIR/test2.php

quota -s

ssh --version
ssh -V

exit

# -----

cd /tmp
rm -rf mpfr-2.3.2

cd $OPENSHIFT_DATA_DIR
rm -rf var etc
rm -f fastjar-0.97.tar.gz gcc-4.4.7-16.el6.src.rpm protoize.1 README.libgcjwebplugin.so
ls -lang

# -----

# convert --help

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

if [ 1 -eq 0 ];then
cd /tmp

gmp_version=4.3.2


wget -nc -q http://ftp.jaist.ac.jp/pub/GNU/gmp/gmp-${gmp_version}.tar.bz2
rm -rf gmp-${gmp_version}
tar jxf gmp-${gmp_version}.tar.bz2
cd gmp-${gmp_version}
./configure \
 --mandir=/tmp/man \
 --infodir=/tmp/info \
 --prefix=${OPENSHIFT_DATA_DIR}/local
time make -j4
make install

cd /tmp

mpfr_version=2.4.2

wget -nc -q http://mpfr.loria.fr/mpfr-${mpfr_version}/mpfr-${mpfr_version}.tar.bz2
rm -rf mpfr-${mpfr_version}
tar jxf mpfr-${mpfr_version}.tar.bz2
cd mpfr-${mpfr_version}
./configure  \
 --mandir=/tmp/man \
 --infodir=/tmp/info \
 --prefix=${OPENSHIFT_DATA_DIR}/local \
 --disable-maintainer-mode \
 --disable-dependency-tracking
time make -j4
make install

cd /tmp

mpc_version=0.8.2

rm -rf mpc-${mpc_version}
wget -nc -q http://www.multiprecision.org/mpc/download/mpc-${mpc_version}.tar.gz
rm -rf mpc-${mpc_version}
tar zxf mpc-${mpc_version}.tar.gz
cd mpc-${mpc_version}
./configure  \
 --mandir=/tmp/man \
 --infodir=/tmp/info \
 --prefix=${OPENSHIFT_DATA_DIR}/local \
 --with-mpfr=${OPENSHIFT_DATA_DIR}/local \
 --with-gmp=${OPENSHIFT_DATA_DIR}/local \
 --disable-dependency-tracking
time make -j4
make install
fi

tree ${OPENSHIFT_DATA_DIR}/local

cd /tmp

rm -rf
mkdir 20160523
cd 20160523

# export LD_LIBRARY_PATH=/usr/lib64

wget -q -nc http://mirrors.concertpass.com/gcc/releases/gcc-4.4.7/gcc-core-4.4.7.tar.bz2
tar xf gcc-core-4.4.7.tar.bz2
ls -lang
cd gcc*
time ./configure \
 --with-mpc=${OPENSHIFT_DATA_DIR}/local/ \
 --with-mpfr=${OPENSHIFT_DATA_DIR}/local \
 --with-gmp=${OPENSHIFT_DATA_DIR}/local \
 --disable-libquadmath \
 --disable-libquadmath-support
time make -j4

quota -s
echo "FINISH"
exit
