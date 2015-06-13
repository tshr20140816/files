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

wget http://ftp.jaist.ac.jp/pub/GNU/glibc/glibc-${glibc_version}.tar.xz
tar Jxf glibc-${glibc_version}.tar.xz
mkdir glibc-${glibc_version}/work
pushd glibc-${glibc_version}/work
../configure --prefix=${OPENSHIFT_TMP_DIR}/local \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --infodir=${OPENSHIFT_TMP_DIR}/info
# over 30min
time make -j$(grep -c -e processor /proc/cpuinfo)
popd > /dev/null
time tar Jcf maked_glibc-${glibc_version}.tar.xz glibc-${glibc_version}
cp maked_glibc-${glibc_version}.tar.xz ${OPENSHIFT_DATA_DIR}/
rm -rf glibc-${glibc_version}
rm -f glibc-${glibc_version}.tar.xz
popd > /dev/null

# ***** ld.gold *****

bison_version=3.0.4
binutils_version=2.25

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

# *** bison ***

wget http://ftp.jaist.ac.jp/pub/GNU/bison/bison-${bison_version}.tar.xz
tar Jxf bison-${bison_version}.tar.xz
pushd bison-${bison_version}
./configure --prefix=${OPENSHIFT_TMP_DIR}/local
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null
rm -rf ./bison-${bison_version}
rm -f bison-${bison_version}.tar.xz
tree ./local

strip --strip-all ./local/bin/bison ./local/lib/liby.a

export PATH=${OPENSHIFT_TMP_DIR}/local/bin:$PATH

# ***  ld.gold ***

wget http://ftp.jaist.ac.jp/pub/GNU/binutils/binutils-${binutils_version}.tar.gz
tar zxf binutils-${binutils_version}.tar.gz
pushd binutils-${binutils_version} > /dev/null
./configure
time make -j$(grep -c -e processor /proc/cpuinfo)
pushd gold > /dev/null
./configure --prefix=${OPENSHIFT_TMP_DIR}/local
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null
popd > /dev/null
rm -rf binutils-${binutils_version}
rm -f binutils-${binutils_version}.tar.gz
strip --strip-all ./local/bin/ld.gold
cp ./local/bin/ld.gold ${OPENSHIFT_DATA_DIR}/
popd > /dev/null
