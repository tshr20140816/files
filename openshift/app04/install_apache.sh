#!/bin/bash

set -x

cd /tmp

wget http://ftp.riken.jp/net/apache//httpd/httpd-2.2.29.tar.bz2
tar jxf httpd-2.2.29.tar.bz2
cd httpd-2.2.29

./configure --config-cache
mv config.cache config.cache.apache
./configure --cache-file="config.cache.apache" 

# CC="ccache gcc" CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s" CXXFLAGS="-O2 -march=native -pipe" \
#  ./configure \
#  --prefix=${OPENSHIFT_DATA_DIR}/apache \
#  --mandir=/tmp/man \
#  --docdir=/tmp/doc \
#  --enable-mods-shared='all proxy'
