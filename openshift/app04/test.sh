#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

rm -f test.txt
string_data="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_!&=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_!&="
# 130
for i in $(seq 10)
do
    random=$(((RANDOM % 132) + 1 ))
    tmp_str=${string_data:${random}:1}
    echo ${tmp_str}
done

post_data='dummytext=&act=post&name=tenv&dai=bundler&msg=1.1.1&email=&site=&col=1&pwd=xxx&pre=0'
