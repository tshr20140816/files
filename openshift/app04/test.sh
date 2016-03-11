#!/bin/bash

echo "1123"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

rm -f httpd-2.2.31.tar.bz2
rm -rf httpd-2.2.31
rm -rf apache
wget http://ftp.riken.jp/net/apache/httpd/httpd-2.2.31.tar.bz2
tar jxf httpd-2.2.31.tar.bz2
cd httpd-2.2.31
./configure --prefix=/tmp/apache
time make
time make install

find /tmp/apache -name "*" -mindepth 2 -type f -print0 \
 | xargs -0i file {} \
 | grep -e "not stripped" \
 | grep -v -e "delegated" 

exit
