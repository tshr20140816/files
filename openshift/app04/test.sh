#!/bin/bash

set -x

quota -s

cd /tmp
mkdir work
cd work
wget http://ftp.mozilla.org/pub/mozilla.org/calendar/sunbird/releases/1.0b1/source/sunbird-1.0b1.source.tar.bz2
tar jxf sunbird-1.0b1.source.tar.bz2
rm sunbird-1.0b1.source.tar.bz2
ls -lang
cd sunbird*
./configure --help
ls -lang
quota -s
cd /tmp
rm -rf work

exit

cd /tmp

# cat ${OPENSHIFT_DATA_DIR}/sphinx/etc/*

mkdir work
cd work

wget http://ftp.riken.jp/net/apache//httpd/httpd-2.2.31.tar.bz2
tar jxf httpd-2.2.31.tar.bz2
time tar zcf test.tar.gz httpd-2.2.31
time tar jcf test.tar.bz2 httpd-2.2.31

cd /tmp
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
