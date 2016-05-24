#!/bin/bash

echo "1523"

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
rm -rf ccache-3.2.5 ccache gomi
rm -f ccache-3.2.5.tar.xz
rm -rf nghttp2-1.10.0
rm -rf Python-2.7.11
rm -rf 20160523
rm -f gcc-c++-5.3.1-6.fc23.i686.rpm
rm -f *.patch
rm -f *.bz2
rm -rf gcc*

cd $OPENSHIFT_DATA_DIR
rm -rf bin include lib lib64 libexec local sbin share usr
rm -f fastjar-0.97.tar.gz gcc-4.4.7-16.el6.src.rpm protoize.1 README.libgcjwebplugin.so
ls -lang

# -----

# convert --help

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

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

tree ${OPENSHIFT_DATA_DIR}/local

cd /tmp

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
# time make -j2

find / -name libgmp.so.3 -print 2>/dev/null
find / -name libmpfr.so.1 -print 2>/dev/null
find / -name libmpc.so.2 -print 2>/dev/null

quota -s
echo "FINISH"
exit
