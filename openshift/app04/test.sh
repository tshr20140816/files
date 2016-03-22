#!/bin/bash

echo "1057"

set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

export GNUPGHOME=${OPENSHIFT_DATA_DIR}/.gnupg
rm -rf ${GNUPGHOME}
mkdir ${GNUPGHOME}
chmod 700 ${GNUPGHOME}
gpg --list-keys
echo "keyserver hkp://keyserver.ubuntu.com:80" >> ${GNUPGHOME}/gpg.conf
chmod 600 ${GNUPGHOME}/gpg.conf

cd /tmp

ls -lang

rm -f parallel-latest.tar.bz2.sig
rm -f parallel-latest.tar.bz2

wget http://ftp.gnu.org/gnu/parallel/parallel-latest.tar.bz2.sig
wget http://ftp.jaist.ac.jp/pub/GNU/parallel/parallel-latest.tar.bz2

gpg --recv-keys $(gpg --verify parallel-latest.tar.bz2.sig 2>&1 | grep "RSA key ID" | awk '{print $NF}')

exit
