#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

rm -f test.txt
string_data="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_!&="
string_data="${string_data}${string_data}${string_data}${string_data}${string_data}"
set +x
for i in $(seq 50000)
do
    random=$(((RANDOM % 330) + 1 ))
    tmp_str="${string_data:${random}:1}${string_data:0:$((random - 0))}${string_data:$((random + 1))}"
    string_data=${tmp_str}
done
set -x
echo ${string_data} > test.txt

post_data='dummytext=&act=post&name=tenv&dai=bundler&msg=1.1.1&email=&site=&col=1&pwd=xxx&pre=0'
