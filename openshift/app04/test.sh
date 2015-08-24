#!/bin/bash

set -x

ssh -V

exit

quota -s

cd /tmp

export PATH="${OPENSHIFT_TMP_DIR}/gcc/bin:$PATH"
export LD_LIBRARY_PATH="${OPENSHIFT_TMP_DIR}/gcc/lib64:$LD_LIBRARY_PATH"
export CC=gcc-493
export CXX=gcc-493
export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

gcc-493 --version

distcc_version=3.1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2
tar jxf distcc-${distcc_version}.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/distcc \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --without-avahi \
 --disable-Werror
time make -j$(grep -c -e processor /proc/cpuinfo)

popd > /dev/null

cd /tmp
rm -f distcc-${distcc_version}.tar.bz2*
rm -rf distcc-${distcc_version}
