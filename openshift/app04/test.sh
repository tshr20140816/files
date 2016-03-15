#!/bin/bash

echo "0928"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 1000000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

# ls -lang

curl http://ftp.riken.jp/net/apache//httpd/httpd-2.2.31.tar.bz2 -o /dev/null &

pgrep -fl pgrep
pgrep -fl curl
pgrep -fl curl | grep -c httpd
pgrep -fl pgrep

wait

exit
