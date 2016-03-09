#!/bin/bash

echo "0948"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

# java -jar ${OPENSHIFT_DATA_DIR}/compiler.jar --help
# exit

rm -f test.php
wget https://github.com/tshr20140816/files/raw/master/openshift/app04/test.php

php test.php

ls -lang

exit
