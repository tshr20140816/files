#!/bin/bash

# 1508

export TZ=JST-9

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

set -x

find / -name apxs -print 2>/dev/null

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

cflag_data=$(gcc -march=native -E -v - </dev/null 2>&1 | sed -n 's/.* -v - //p')
export CFLAGS="-O2 ${cflag_data} -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

cd /tmp
rm -rf httpd-2.2.29
rm -f httpd-2.2.29.tar.bz2
wget http://ftp.riken.jp/net/apache//httpd/httpd-2.2.29.tar.bz2

tar jxf httpd-2.2.29.tar.bz2
cd httpd-2.2.29
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/apache \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --enable-mods-shared='all proxy'

time make -j4

grep -r ${OPENSHIFT_APP_UUID} ./
