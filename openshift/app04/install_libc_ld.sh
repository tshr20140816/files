#!/bin/bash

set -x

export TZ=JST-9

export CFLAGS="-O2 -march=core2 -maes -mavx -mcx16 -mpclmul -mpopcnt -msahf"
export CFLAGS="${CFLAGS} -msse -msse2 -msse3 -msse4 -msse4.1 -msse4.2 -mssse3 -mtune=generic"
export CFLAGS="${CFLAGS} -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

# ***** libc.so *****

find /lib -name "libc-*.so" -print

glibc_version=2.12.2

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

wget http://ftp.gnu.org/gnu/glibc/glibc-${glibc_version}.tar.xz
tar Jxf glibc-${glibc_version}.tar.xz
mkdir glibc-${glibc_version}/work
pushd glibc-${glibc_version}/work
../configure --prefix=${OPENSHIFT_TMP_DIR}/local \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --infodir=${OPENSHIFT_TMP_DIR}/info
time make -j4
popd > /dev/null
time tar Jcf maked_glibc-${glibc_version}.tar.xz glibc-${glibc_version}
popd > /dev/null
