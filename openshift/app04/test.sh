#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

xz_version=5.2.1

rm -f xz-${xz_version}.tar.xz
rm -rf xz-${xz_version}
rm -rf ${OPENSHIFT_DATA_DIR}/xz

wget http://tukaani.org/xz/xz-${xz_version}.tar.xz

tar Jxf xz-${xz_version}.tar.xz
cd xz-${xz_version}
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/xz \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --disable-doc
time make -j4
make install
