#!/bin/bash

# 1508

export TZ=JST-9

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

set -x

cd /tmp
rm -f httpd-2.2.29.tar.bz2

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

cd ${OPENSHIFT_DATA_DIR}/apache2/bin
cp httpd httpd.org
./httpd -v
file httpd
strip --strip-all httpd
file httpd
./httpd -v

exit

cflag_data=$(gcc -march=native -E -v - </dev/null 2>&1 | sed -n 's/.* -v - //p')
export CFLAGS="-O2 ${cflag_data} -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

cd /tmp

wget http://ftp.riken.jp/net/apache//httpd/httpd-2.2.29.tar.bz2

tar jxf httpd-2.2.29.tar.bz2
cd httpd-2.2.29
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/apache2 \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --enable-mods-shared='all proxy'

time make -j4
make install
cd $OPENSHIFT_DATA_DIR
rm -rf ./apache2/manual

cd apache2
./bin/apachectl -v

tree ./
