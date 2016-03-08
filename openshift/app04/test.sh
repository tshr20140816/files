#!/bin/bash

echo "0914"

set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

rm -f 300000000

yuicompressor_version="2.4.8"
rm -f yuicompressor-${yuicompressor_version}.jar
rm -f cdm.css

exit
