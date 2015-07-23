#!/bin/bash

# 1414

set -x

cd /tmp

ls -lang

rm -rf rpm-4.8.0
rm -rf usr
rm -rf etc

mkdir nss
cd nss
wget http://ftp-srv2.kddilabs.jp/Linux/packages/CentOS/6.6/os/x86_64/Packages/nss-devel-3.16.1-14.el6.x86_64.rpm
rpm2cpio nss-devel-3.16.1-14.el6.x86_64.rpm | cpio -idmv
tree ./

exit

# wget https://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_3_19_2_RTM/src/nss-3.19.2.tar.gz

tar zxf nss-3.19.2.tar.gz
cd nss-3.19.2
export NSPR_INCLUDE_DIR=/usr/include/nspr4
export USE_64=1
pwd
make

exit

# find / -name sechash.h -print 2>/dev/null

# wget https://ftp.mozilla.org/pub/mozilla.org/mozilla.org/security/nss/releases/NSS_3_19_2_RTM/src/nss-3.19.2-with-nspr-4.10.8.tar.gz

# tar zxf nss-3.19.2-with-nspr-4.10.8.tar.gz
# cd nss-3.19.2-with-nspr-4.10.8
# ./configure --help
# tree ./
# exit

# wget http://rpm.org/releases/rpm-4.8.x/rpm-4.8.0.tar.bz2
# tar jxf rpm-4.8.0.tar.bz2

export CPPFLAGS="-I/usr/include/nspr4 -I/tmp/nss-3.19.2/nss/lib/cryptohi"

cd rpm-4.8.0
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/rpm --disable-largefile
time make -j4
make install

# rpm --help

# wget http://ftp-srv2.kddilabs.jp/Linux/packages/fedora/releases/21/Server/x86_64/os/Packages/g/gcc-4.9.2-1.fc21.x86_64.rpm

# rpm -ivh --prefix=${OPENSHIFT_DATA_DIR}/gcc gcc-4.9.2-1.fc21.x86_64.rpm

# tree ${OPENSHIFT_DATA_DIR}/gcc
