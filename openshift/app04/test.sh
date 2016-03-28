#!/bin/bash

echo "1041"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang
# rm -f xymon-4.3.27.tar.gz*
# rm -rf xymon-4.3.27
# wget -O xymon-4.3.27.tar.gz http://downloads.sourceforge.net/project/xymon/Xymon/4.3.27/xymon-4.3.27.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fxymon%2Ffiles%2FXymon%2F&ts=1459128647&use_mirror=iweb

tar xzf xymon-4.3.27.tar.gz

ls -lang

cd xymon-4.3.27

ls -lang

./configure --help
# time make

exit
