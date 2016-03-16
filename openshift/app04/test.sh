#!/bin/bash

echo "0829"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp
# wget http://www.redmine.org/releases/redmine-2.6.10.tar.gz
# cd ${OPENSHIFT_DATA_DIR}
# mv -f /tmp/redmine-2.6.10.tar.gz ./

ls -lang

mv -f d1.txt sv.txt

cat sv.txt

exit
