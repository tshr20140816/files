#!/bin/bash

echo "0858"

set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

yuicompressor_version="2.4.8"
wget https://github.com/yui/yuicompressor/releases/download/v${yuicompressor_version}/yuicompressor-${yuicompressor_version}.jar

ls -lang

cd ${OPENSHIFT_DATA_DIR}

rm -rf tt-rss.git

unzip ttrss_archive.zip

ls -lang

find ./ -name *.css -print

exit
