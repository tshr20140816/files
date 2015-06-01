#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

# * gpg *

rm -rf ${OPENSHIFT_DATA_DIR}/.gnupg
mkdir ${OPENSHIFT_DATA_DIR}/.gnupg
export GNUPGHOME=${OPENSHIFT_DATA_DIR}/.gnupg
chmod 700 ${GNUPGHOME}
gpg --list-keys
echo "keyserver hkp://keyserver.ubuntu.com:80" >> ${GNUPGHOME}/gpg.conf

cat ${GNUPGHOME}/gpg.conf

rm -f xz-5.2.1.tar.xz
rm -f xz-5.2.1.tar.xz.sig
rm -rf xz-5.2.1
wget http://tukaani.org/xz/xz-5.2.1.tar.xz

wget http://tukaani.org/xz/xz-5.2.1.tar.xz.sig

gpg --recv-keys $(gpg --verify xz-5.2.1.tar.xz.sig 2>&1 | grep "RSA key ID" | awk '{print $NF}')
gpg --verify xz-5.2.1.tar.xz.sig 2>&1
