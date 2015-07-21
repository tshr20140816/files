#!/bin/bash

set -x

cd /tmp

rm gcc-4.8.4.tar.bz2
rm -rf gcc-4.8.4

exit

wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.8.4/gcc-4.8.4.tar.bz2
tar jxf gcc-4.8.4.tar.bz2
cd gcc-4.8.4
mkdir work
cd work
../configure --help
../configure --prefix=${OPENSHIFT_DATA_DIR}/gnu
