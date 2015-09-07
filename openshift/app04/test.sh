#!/bin/bash

set -x

quota -s

cd /tmp

export CFLAGS="-O2 ${cflag_data} -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"
    
sphinx_version=2.2.9

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
     
time make -j4

