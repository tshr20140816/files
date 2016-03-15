#!/bin/bash

echo "1148"

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

wget https://github.com/tshr20140816/files/raw/master/openshift/app04/test.php
cp test.php ${OPENSHIFT_REPO_DIR}/test.php

cat test.php

cat d1.txt
cat d2.txt

exit
