#!/bin/bash

# 1414

set -x

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

cd /tmp

rm -rf /tmp/gomi
# rm -rf gcc
rm -rf gmp*
rm -rf mpfr*
rm -rf mpc*

if [ 1 -eq 1 ]; then
cd /tmp

wget http://ftp.jaist.ac.jp/pub/GNU/gmp/gmp-4.3.2.tar.bz2
tar jxf gmp-4.3.2.tar.bz2
cd gmp-4.3.2
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
fi

cd /tmp

if [ 1 -eq 1 ]; then
wget http://ftp.jaist.ac.jp/pub/GNU/mpfr/mpfr-2.4.2.tar.xz
tar Jxf mpfr-2.4.2.tar.xz
cd mpfr-2.4.2
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static --with-gmp=/tmp/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
fi

cd /tmp

if [ 1 -eq 1 ]; then
wget http://ftp.jaist.ac.jp/pub/GNU/mpc/mpc-1.0.3.tar.gz
tar zxf mpc-1.0.3.tar.gz
cd mpc-1.0.3
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static --with-gmp=/tmp/gcc --with-mpfr=/tmp/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
fi

cd /tmp

quota -s
ls -lang
