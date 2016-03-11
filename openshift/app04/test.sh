#!/bin/bash

echo "1123"

set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

rm -f httpd-2.2.31.tar.bz2
rm -rf httpd-2.2.31

time find /tmp/apache -name "*" -mindepth 2 -type f -print0 \
 | xargs -0i file {} \
 | grep -e "not stripped" \
 | grep -v -e "delegated" > /tmp/strip_starget.txt

cat /tmp/strip_starget.txt | xargs -t -P 1 -n 1 time strip --strip-debug

exit
