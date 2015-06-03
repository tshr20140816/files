#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

head --help

rm -f *.xz

libmemcached_version=1.0.18

# wget https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz

# tar zxf libmemcached-${libmemcached_version}.tar.gz

time tar cf - libmemcached-${libmemcached_version} \
 | xz -f  --memlimit=256MiB \
 > test.tar.xz

ls -lang
