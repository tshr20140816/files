#!/bin/bash

echo "1308"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

rm -f httpd-2.2.31.tar.bz2
rm -rf httpd-2.2.31
rm -rf apache
rm -rf 20160311

ls -lang

# time strip --strip-debug /tmp/apache/bin/rotatelogs 

exit
