#!/bin/bash

set -x

quota -s

# cat ${OPENSHIFT_DATA_DIR}/sphinx/etc/*

cd /tmp

rm hpn-6_9_P1.zip*
rm openssh-6.9p1.tar.gz*
rm -rf local
rm -rf gomi
rm -rf man
rm -rf openssh-portable-hpn-6_9_P1
rm -rf openssh-6.9p1

ls -lang

ls -lang ${OPENSHIFT_DATA_DIR}

exit


mkdir work

wget http://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/openssh-6.9p1.tar.gz
wget https://github.com/rapier1/openssh-portable/archive/hpn-6_9_P1.zip

tar xfz openssh-6.9p1.tar.gz
unzip hpn-6_9_P1.zip

tree ./

rm -rf work

exit

cd /tmp

export CFLAGS="-O2 ${cflag_data} -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"
    
sphinx_version=2.2.10

rm -rf sphinx-${sphinx_version}-release
rm sphinx-${sphinx_version}-release.tar.gz*

wget http://sphinxsearch.com/files/sphinx-${sphinx_version}-release.tar.gz
tar zxf sphinx-${sphinx_version}-release.tar.gz

cd sphinx-${sphinx_version}-release
./configure --help
./configure \
     --prefix=${OPENSHIFT_DATA_DIR}/sphinx \
     --mandir=/tmp/gomi \
     --infodir=/tmp/gomi \
     --docdir=/tmp/gomi \
     --disable-dependency-tracking \
     --disable-id64 \
     --with-mysql \
     --without-syslog \
     --without-unixodbc
     
time make
make install

cd /tmp

rm -rf sphinx-${sphinx_version}-release
rm -f sphinx-${sphinx_version}-release.tar.gz*

tree ${OPENSHIFT_DATA_DIR}/sphinx
