#!/bin/bash

set -x

quota -s

cd /tmp

rm -rf delegate9.9.13
rm delegate9.9.13.tar.gz

mkdir work
cd work

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

wget http://www.delegate.org/anonftp/DeleGate/delegate9.9.13.tar.gz

tar zxf delegate9.9.13.tar.gz

cd delegate9.9.13

time make -j4 ADMIN=user@rhcloud.local

mkdir ${OPENSHIFT_DATA_DIR}/delegate/
cp src/delegated ${OPENSHIFT_DATA_DIR}/delegate/

cd /tmp
rmdir -rf work
