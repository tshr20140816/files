#!/bin/bash

set -x

cd /tmp

quota -s

# find / -name nspr.h -print 2>/dev/null
find / -name nss.h -print 2>/dev/null

exit

# wget http://rpm.org/releases/rpm-4.8.x/rpm-4.8.0.tar.bz2
# tar jxf rpm-4.8.0.tar.bz2

export CPPFLAGS="-I/usr/include/nspr4"

cd rpm-4.8.0
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/rpm --disable-largefile
time make -j4
make install

# rpm --help

# wget http://ftp-srv2.kddilabs.jp/Linux/packages/fedora/releases/21/Server/x86_64/os/Packages/g/gcc-4.9.2-1.fc21.x86_64.rpm

# rpm -ivh --prefix=${OPENSHIFT_DATA_DIR}/gcc gcc-4.9.2-1.fc21.x86_64.rpm

# tree ${OPENSHIFT_DATA_DIR}/gcc
