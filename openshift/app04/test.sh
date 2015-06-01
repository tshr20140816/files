#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

apache_version=2.2.29

rm -f httpd-${apache_version}.tar.bz2
rm -rf httpd-${apache_version}
rm -f test.tar.xz

wget http://ftp.riken.jp/net/apache//httpd/httpd-${apache_version}.tar.bz2

tar jxf httpd-${apache_version}.tar.bz2

for i in $(seq 10)
do
rm -f test.tar.xz
time tar Jcf test.tar.xz httpd-${apache_version} 2>&1

rm -f test.tar.xz
time tar cf test.tar.xz --use-compress-prog=${OPENSHIFT_DATA_DIR}/xz/bin/xz httpd-${apache_version} 2>&1
done
