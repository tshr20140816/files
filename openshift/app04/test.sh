#!/bin/bash

set -x

quota -s

# cat ${OPENSHIFT_DATA_DIR}/sphinx/etc/*

cd /tmp

mkdir work
cd work

wget https://tt-rss.org/gitlab/fox/tt-rss/repository/archive.zip?ref=master -O archive.zip
unzip archive.zip

tree ./

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
