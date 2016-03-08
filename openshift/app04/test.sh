#!/bin/bash

echo "0840"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

rm -f compiler-latest.zip
wget http://dl.google.com/closure-compiler/compiler-latest.zip
unzip compiler-latest.zip
rm -f compiler-latest.zip

mv -f ./compiler.jar ${OPENSHIFT_DATA_DIR}/compiler.jar

ls -lang

ls -lang ${OPENSHIFT_DATA_DIR}

exit
