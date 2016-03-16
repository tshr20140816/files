#!/bin/bash

echo "1327"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

# ls -lang

rm -f test.php*
rm -f nkf-2.1.4.tar.gz
rm -rf nkf-2.1.4
rm -f index.html

whereis nkf

wget http://iij.dl.osdn.jp/nkf/64158/nkf-2.1.4.tar.gz
tar zxf nkf-2.1.4.tar.gz
ls -lang

cd nkf-2.1.4
cat Makefile

sed -e "s|-g -O2 -Wall -pedantic|-O2 -march=native -pipe -fomit-frame-pointer -s|g" Makefile > Makefile

cat Makefile

# ./configure --help
make -p
time make

tree ./

file nkf
ls -lang nkf
strip --strip-all nkf
file nkf
ls -lang nkf

exit
