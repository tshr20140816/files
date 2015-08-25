#!/bin/bash

set -x

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

# tree /tmp/work

rm glibc-devel-2.12-1.166.el6.i686.rpm
# rm -rf /tmp/work

quota -s

cd /tmp

# tree /tmp/gcc

# export PATH="${OPENSHIFT_TMP_DIR}/gcc/bin:$PATH"
# export LD_LIBRARY_PATH="${OPENSHIFT_TMP_DIR}/gcc/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/tmp/work/usr/lib:$LD_LIBRARY_PATH"
# export CC=gcc-493
# export CXX=gcc-493
# export CFLAGS="-m32 -O2 -march=native -fomit-frame-pointer -s -pipe"
export CFLAGS="-m32"
export CXXFLAGS="${CFLAGS}"
# export LD=ld.gold
# export PATH="/tmp/work/usr/bin:$PATH"
# export CC="gcc -m32"
# export LD="gcc -m32"
# export AS="gcc -c -m32"
# export LDFLAGS="-L/tmp/work/usr/lib"

# gcc-493 --version

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget https://files3-20150207.rhcloud.com/files/httpd-2.2.31.tar.bz2
tar jxf httpd-2.2.31.tar.bz2
popd > /dev/null
cd /tmp
cd httpd-2.2.31
./configure --help
# cat configure
./configure
cd srclib/apr
cat config.log
# time make -j$(grep -c -e processor /proc/cpuinfo)

cd /tmp
rm -f httpd-2.2.31.tar.bz2
rm -rf httpd-2.2.31
rm -rf /tmp/work
