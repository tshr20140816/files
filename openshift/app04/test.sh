#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

string_data=$(cat test.txt)
p_data=${string_data:32:1}${string_data:44:1}${string_data:190:1}
echo ${p_data} > p_data.txt

post_data='dummytext=&act=post&name=tenv&dai=bundler&msg=1.1.1&email=&site=&col=1&pwd=xxx&pre=0'
