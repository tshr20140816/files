#!/bin/bash

export TZ=JST-9

set -x

cd /tmp

gmp_version=4.3.2

[ -f gmp-${gmp_version}.tar.bz2 ] || wget http://ftp.jaist.ac.jp/pub/GNU/gmp/gmp-${gmp_version}.tar.bz2
tar jxf gmp-${gmp_version}.tar.bz2
cd gmp-${gmp_version}
./configure \
 --mandir=/tmp/man \
 --infodir=/tmp/info \
 --prefix=${OPENSHIFT_DATA_DIR}/local
time make
make install

cd /tmp

mpfr_version=2.3.2

[ -f mpfr-${mpfr_version}.tar.bz2 ] || wget http://mpfr.loria.fr/mpfr-${mpfr_version}/mpfr-${mpfr_version}.tar.bz2
tar jxf mpfr-${mpfr_version}.tar.bz2
cd mpfr-${mpfr_version}
./configure  \
 --mandir=/tmp/man \
 --infodir=/tmp/info \
 --prefix=${OPENSHIFT_DATA_DIR}/local \
 --disable-maintainer-mode \
 --disable-dependency-tracking
time make
make install

cd /tmp

mpc_version=0.8.2

rm -rf mpc-${mpc_version}
[ -f mpc-${mpc_version}.tar.gz ] || wget http://www.multiprecision.org/mpc/download/mpc-${mpc_version}.tar.gz
tar zxf mpc-${mpc_version}.tar.gz
cd mpc-${mpc_version}
./configure  \
 --mandir=/tmp/man \
 --infodir=/tmp/info \
 --prefix=${OPENSHIFT_DATA_DIR}/local \
 --with-mpfr=${OPENSHIFT_DATA_DIR}/local \
 --with-gmp=${OPENSHIFT_DATA_DIR}/local \
 --disable-dependency-tracking
time make
make install

cd /tmp

rm -rf gmp-${gmp_version}
rm -rf mpfr-${mpfr_version}
rm -rf mpc-${mpc_version}

gcc_version=4.6.4

[ -f gcc-core-${gcc_version}.tar.bz2 ] || wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-${gcc_version}/gcc-core-${gcc_version}.tar.bz2
tar jxf gcc-core-${gcc_version}.tar.bz2
cd gcc-${gcc_version}
time ./configure \
 --with-mpc=${OPENSHIFT_DATA_DIR}/local/ \
 --with-mpfr=${OPENSHIFT_DATA_DIR}/local \
 --with-gmp=${OPENSHIFT_DATA_DIR}/local \
 --disable-libquadmath \
 --disable-libquadmath-support
time make
