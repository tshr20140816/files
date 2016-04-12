#!/bin/bash

set -x

cd /tmp

# export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
# export CXXFLAGS="${CFLAGS}"

[ ! -f gmp-4.3.2.tar.bz2 ] && wget http://ftp.jaist.ac.jp/pub/GNU/gmp/gmp-4.3.2.tar.bz2
rm -rf gmp-4.3.2
tar jxf gmp-4.3.2.tar.bz2
cd gmp-4.3.2
./configure --help
./configure --prefix=$OPENSHIFT_DATA_DIR/gcc --disable-shared --enable-static \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j2
make install
cd /tmp
rm -rf gmp-4.3.2
rm -f gmp-4.3.2.tar.bz2

cd /tmp

[ ! -f mpfr-2.4.2.tar.xz ] && wget http://ftp.jaist.ac.jp/pub/GNU/mpfr/mpfr-2.4.2.tar.xz
rm -rf mpfr-2.4.2
tar Jxf mpfr-2.4.2.tar.xz
cd mpfr-2.4.2
./configure --help
./configure --prefix=$OPENSHIFT_DATA_DIR/gcc --disable-shared --enable-static --with-gmp=$OPENSHIFT_DATA_DIR/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j2
make install
cd /tmp
rm -rf mpfr-2.4.2
rm -f mpfr-2.4.2.tar.xz

cd /tmp

[ ! -f mpc-1.0.3.tar.gz ] && wget http://ftp.jaist.ac.jp/pub/GNU/mpc/mpc-1.0.3.tar.gz
rm -rf mpc-1.0.3
tar zxf mpc-1.0.3.tar.gz
cd mpc-1.0.3
./configure --help
./configure --prefix=$OPENSHIFT_DATA_DIR/gcc --disable-shared --enable-static --with-gmp=$OPENSHIFT_DATA_DIR/gcc --with-mpfr=$OPENSHIFT_DATA_DIR/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
cd /tmp
rm -rf mpc-1.0.3
rm -f mpc-1.0.3.tar.gz

cd /tmp

[ ! -f gcc-4.9.3.tar.bz2 ] && wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.9.3/gcc-4.9.3.tar.bz2

rm -rf gcc-4.9.3
tar jxf gcc-4.9.3.tar.bz2
rm -f gcc-4.9.3.tar.bz2

cd gcc-4.9.3
mkdir work
cd work
../configure --help
../configure --with-gmp=$OPENSHIFT_DATA_DIR/gcc --with-mpfr=$OPENSHIFT_DATA_DIR/gcc --prefix=$OPENSHIFT_DATA_DIR/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --disable-multilib --enable-stage1-languages=c,c++ \
 --enable-stage1-checking=c,c++ target=x86_64-unknown-linux-gnu \
 --disable-shared --enable-static \
 --program-suffix=-493 \
 --disable-libjava --disable-libgo --disable-libgfortran --enable-languages=c,c++
time make
make install
rm -rf /tmp/gcc-4.9.3

cd /tmp
tree $OPENSHIFT_DATA_DIR/gcc

# http://ameblo.jp/sora8492/entry-11838796776.html
