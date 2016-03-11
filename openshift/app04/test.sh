#!/bin/bash

echo "1158"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

rm -f httpd-2.2.31.tar.bz2
rm -rf httpd-2.2.31

mkdir 20160311
cd 20160311
cp -f /tmp/apache/lib/libapr-1.so.0.5.2 ./
cp -f /tmp/apache/lib/apr-util-1/apr_dbd_pgsql-1.so ./
cp -f /tmp/apache/lib/apr-util-1/apr_dbd_sqlite3-1.so ./
cp -f /tmp/apache/lib/apr-util-1/apr_dbd_odbc-1.so ./
cp -f /tmp/apache/lib/libaprutil-1.so.0.5.4 ./
cp -f /tmp/apache/bin/htpasswd ./
cp -f /tmp/apache/bin/htdigest ./
cp -f /tmp/apache/bin/rotatelogs ./
cp -f /tmp/apache/bin/logresolve ./
cp -f /tmp/apache/bin/ab ./
cp -f /tmp/apache/bin/htdbm ./
cp -f /tmp/apache/bin/htcacheclean ./
cp -f /tmp/apache/bin/httxt2dbm ./
cp -f /tmp/apache/bin/checkgid ./
cp -f /tmp/apache/bin/httpd ./

ls -lang



# time strip --strip-debug /tmp/apache/bin/rotatelogs 

exit
