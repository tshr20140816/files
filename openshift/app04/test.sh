#!/bin/bash

# 1414

set -x

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

cd /tmp

rm -rf gmp*

cd /tmp

wget http://ftp.jaist.ac.jp/pub/GNU/gmp/gmp-4.3.2.tar.bz2
tar jxf gmp-4.3.2.tar.bz2
cd gmp-4.3.2
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static --infodir=/dev/null --mandir=/dev/null --docdir=/dev/null
time make -j4
make install

cd /tmp

quota -s
ls -lang
