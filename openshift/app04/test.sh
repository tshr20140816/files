#!/bin/bash

echo "1445"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

rm -f test.php
wget https://github.com/tshr20140816/files/raw/master/openshift/app04/test.php

cp -f ./test.php ${OPENSHIFT_REPO_DIR}/

ls -lang

exit
