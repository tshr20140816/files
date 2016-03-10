#!/bin/bash

echo "1351"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

cat << '__HEREDOC__' > test.txt
111@aaa-bbb.test.local
222@aaa-bbb.test.local
333@aaa-bbb.test.local
abc@aaa-bbb.test.local
__HEREDOC__

sed -e 's/^.\+\?@//g' test.txt

cat test.txt

line=$((10%3+1))
sed -n -e ${line}p test.txt

ps auwx

exit
