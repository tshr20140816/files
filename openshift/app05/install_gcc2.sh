#!/bin/bash

set -x

cd /tmp

# export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
# export CXXFLAGS="${CFLAGS}"

wget http://ftp.jaist.ac.jp/pub/GNU/gmp/gmp-4.3.2.tar.bz2
tar jxf gmp-4.3.2.tar.bz2
cd gmp-4.3.2
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j2
make install
rm -rf /tmp/gmp-4.3.2

cd /tmp

wget http://ftp.jaist.ac.jp/pub/GNU/mpfr/mpfr-2.4.2.tar.xz
tar Jxf mpfr-2.4.2.tar.xz
cd mpfr-2.4.2
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static --with-gmp=/tmp/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j2
make install
rm -rf /tmp/mpfr-2.4.2

cd /tmp

wget http://ftp.jaist.ac.jp/pub/GNU/mpc/mpc-1.0.3.tar.gz
tar zxf mpc-1.0.3.tar.gz
cd mpc-1.0.3
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static --with-gmp=/tmp/gcc --with-mpfr=/tmp/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j2
make install
rm -rf /tmp/mpc-1.0.3

cd /tmp

wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.9.3/gcc-4.9.3.tar.bz2

tar jxf gcc-4.9.3.tar.bz2

cd gcc-4.9.3
mkdir work
cd work
../configure --help
../configure --with-gmp=/tmp/gcc --with-mpfr=/tmp/gcc --prefix=/tmp/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --disable-multilib --enable-stage1-languages=c,c++ \
 --enable-stage1-checking=c,c++ target=x86_64-unknown-linux-gnu \
 --disable-shared --enable-static \
 --program-suffix=-493 \
 --disable-libjava --disable-libgo --disable-libgfortran --enable-languages=c,c++
time make -j2
make install
rm -rf /tmp/gcc-4.9.3

cd /tmp
tree /tmp/gcc

# http://ameblo.jp/sora8492/entry-11838796776.html
