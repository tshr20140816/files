#!/bin/bash

# Disk quota exceeded

export TZ=JST-9

set -x

cd /tmp

# export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
# export CXXFLAGS="${CFLAGS}"

[ ! -f gmp-4.3.2.tar.bz2 ] && wget http://mirrors.kernel.org/gnu/gmp/gmp-4.3.2.tar.bz2
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

[ ! -f mpfr-2.4.2.tar.xz ] && wget http://mirrors.kernel.org/gnu/mpfr/mpfr-2.4.2.tar.xz
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

[ ! -f mpc-1.0.3.tar.gz ] && wget http://mirrors.kernel.org/gnu/mpc/mpc-1.0.3.tar.gz
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
rm -rf gomi

cd $OPENSHIFT_DATA_DIR

[ ! -f gcc-4.9.3.tar.bz2 ] && wget http://mirrors.kernel.org/gnu/gcc/gcc-4.9.3/gcc-4.9.3.tar.bz2

rm -rf gcc-4.9.3
tar jtf gcc-4.9.3.tar.bz2 > file_list.txt
wc -l file_list.txt
# grep -v -E '^gcc-4.9.3.(libobjc|libgfortran|libgo|libjava)' file_list.txt > tmp1.txt
grep -v -E '^gcc-4.9.3.(libgfortran|libgo|libjava)' file_list.txt > tmp1.txt
wc -l tmp1.txt
grep -v '/$' tmp1.txt > file_list.txt
wc -l file_list.txt
time cat file_list.txt | xargs -P 1 -n 10000 tar jxvf gcc-4.9.3.tar.bz2
rm -f gcc-4.9.3.tar.bz2
quota -s

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
rm -rf $OPENSHIFT_DATA_DIR/gcc-4.9.3

cd /tmp
tree $OPENSHIFT_DATA_DIR/gcc

# http://ameblo.jp/sora8492/entry-11838796776.html
