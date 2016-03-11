#!/bin/bash

echo "1230"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

rm -f httpd-2.2.31.tar.bz2
rm -rf httpd-2.2.31

cd 20160311

ls -lang

time strip --strip-debug ab
time strip --strip-debug apr_dbd_odbc-1.so
time strip --strip-debug apr_dbd_pgsql-1.so
time strip --strip-debug apr_dbd_sqlite3-1.so
time strip --strip-debug checkgid
time strip --strip-debug htcacheclean
time strip --strip-debug htdbm
time strip --strip-debug htdigest
time strip --strip-debug htpasswd
time strip --strip-debug httpd
time strip --strip-debug httxt2dbm
time strip --strip-debug libapr-1.so.0.5.2
time strip --strip-debug libaprutil-1.so.0.5.4
time strip --strip-debug logresolve
time strip --strip-debug rotatelogs

ls -lang

# time strip --strip-debug /tmp/apache/bin/rotatelogs 

exit
