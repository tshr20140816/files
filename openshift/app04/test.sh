#!/bin/bash

set -x

ld --help
ld --version

exit

cd /tmp

wget http://ftpmirror.gnu.org/binutils/binutils-2.25.1.tar.bz2
ls -lkg --full-time binutils-2.25.1.tar.bz2
ls --help
tar jxf binutils-2.25.1.tar.bz2

cd binutils-2.25.1
./configure --help
cd gold
./configure --help
cd /tmp

rm -rf binutils-2.25.1
rm -f binutils-2.25.1.tar.bz2

exit

cd /tmp
mkdir work
cd work

wget http://mirror.centos.org/centos/6.7/os/x86_64/Packages/glibc-devel-2.12-1.166.el6.i686.rpm

# rpm -ivh --prefix=/tmp/lib32 glibc-devel-2.12-1.166.el6.i686.rpm
rpm2cpio glibc-devel-2.12-1.166.el6.i686.rpm | cpio -idmv

# mkdir /tmp/work/usr/bin
# wget https://files3-20150207.rhcloud.com/files/ld.gold
# chmod +x ld.gold
# mv ld.gold ./usr/bin/

tree /tmp/work

rm glibc-devel-2.12-1.166.el6.i686.rpm
# rm -rf /tmp/work

quota -s

cd /tmp

tree /tmp/gcc

# export PATH="${OPENSHIFT_TMP_DIR}/gcc/bin:$PATH"
# export LD_LIBRARY_PATH="${OPENSHIFT_TMP_DIR}/gcc/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/tmp/work/usr/lib:$LD_LIBRARY_PATH"
# export CC=gcc-493
# export CXX=gcc-493
# export CFLAGS="-m32 -O2 -march=native -fomit-frame-pointer -s -pipe"
export CFLAGS="-m32"
export CXXFLAGS="${CFLAGS}"
# export LD=ld.gold
export PATH="/tmp/work/usr/bin:$PATH"
export CC="gcc -m32"
export LD="gcc -m32"
export AS="gcc -c -m32"
export LDFLAGS="-L/tmp/work/usr/lib"

# gcc-493 --version

distcc_version=3.1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2
tar jxf distcc-${distcc_version}.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
./configure --help
# cat configure
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/distcc \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --without-avahi \
 --disable-Werror
cat config.log
time make -j$(grep -c -e processor /proc/cpuinfo)

popd > /dev/null

cd /tmp
rm -f distcc-${distcc_version}.tar.bz2*
rm -rf distcc-${distcc_version}
rm -rf /tmp/work
