#!/bin/bash

set -x

quota -s

cd /tmp

export PATH="${OPENSHIFT_TMP_DIR}/gcc/bin:$PATH"
export LD_LIBRARY_PATH="${OPENSHIFT_TMP_DIR}/gcc/lib64:$LD_LIBRARY_PATH"
export CC=gcc-493
export CXX=gcc-493
export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

gcc-493 --version

mkdir lynx
cd lynx

wget https://files3-20150207.rhcloud.com/files/lynx2.8.7.tar.gz

tar zxf lynx2.8.7.tar.gz --strip-components=1

./configure --help
./configure

time make -j4

cd /tmp

rm -rf lynx
