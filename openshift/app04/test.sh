#!/bin/bash

echo "1024"

set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

cd ~
pwd
# tree

ls -lang php/configuration/etc/conf/
ls -lang php/configuration/etc/conf.d/

cat php/configuration/etc/conf/httpd.conf
cat php/configuration/etc/conf/httpd_nolog.conf
cat php/configuration/etc/conf.d/openshift.conf
cat php/configuration/etc/conf.d/php.conf

exit
