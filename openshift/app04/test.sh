#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

rm -f index.html

url='http://lib20110701.bbs.fc2.com/'

post_data="dummytext=&act=post&name=tenv&dai=bundler&msg=1.1.1&email=&site=&col=1&pwd=$(cat p_data.txt)&pre=0"

wget --post-data="${post_data}" ${url}

cat index.html
