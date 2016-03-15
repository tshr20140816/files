#!/bin/bash

echo "0909"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 1000000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

# ls -lang

curl http://jp2.php.net/get/php-5.6.19.tar.xz/from/this/mirror -o /dev/null &

pgrep -fl pgrep
pgrep -fl curl
pgrep -fl curl | grep -c php
pgrep -fl pgrep

exit
