#!/bin/bash

set -x

quota -s

cd /tmp

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

wget http://ftp.jaist.ac.jp/pub/GNU/gmp/gmp-4.3.2.tar.bz2
tar jxf gmp-4.3.2.tar.bz2
cd gmp-4.3.2
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
rm -rf /tmp/gmp-4.3.2

cd /tmp

wget http://ftp.jaist.ac.jp/pub/GNU/mpfr/mpfr-2.4.2.tar.xz
tar Jxf mpfr-2.4.2.tar.xz
cd mpfr-2.4.2
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static --with-gmp=/tmp/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
rm -rf /tmp/mpfr-2.4.2

cd /tmp

wget http://ftp.jaist.ac.jp/pub/GNU/mpc/mpc-1.0.3.tar.gz
tar zxf mpc-1.0.3.tar.gz
cd mpc-1.0.3
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static --with-gmp=/tmp/gcc --with-mpfr=/tmp/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
rm -rf /tmp/mpc-1.0.3

cd /tmp

wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.4.7/gcc-core-4.4.7.tar.bz2
wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.4.7/gcc-g++-4.4.7.tar.bz2

tar jxf gcc-core-4.4.7.tar.bz2
tar jxf gcc-g++-4.4.7.tar.bz2

cd gcc-4.4.7
make clean
./configure --help
./configure --with-gmp=/tmp/gcc --with-mpfr=/tmp/gcc --prefix=/tmp/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi
nohup make -j2
make install
rm -rf /tmp/gcc-4.4.7

tree /tmp/gcc
