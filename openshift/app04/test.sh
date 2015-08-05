#!/bin/bash

set -x

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

wget http://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/openssh-6.9p1.tar.gz
wget https://github.com/rapier1/openssh-portable/archive/hpn-V_6_9_P1.tar.gz

tar zxf openssh-6.9p1.tar.gz
tar zxf hpn-V_6_9_P1.tar.gz -C ./openssh-6.9p1

cd openssh-6.9p1
./configure --help
./configure
time make -j4

exit

cd /tmp

rm -rf /tmp/gomi
rm -rf gcc
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

time tar Jcf tmp_gcc.tar.xz gcc

tree /tmp/gcc

quota -s
ls -lang
