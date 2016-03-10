#!/bin/bash

echo "1657"

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

curl http://ftp.riken.jp/net/apache//httpd/httpd-2.2.31.tar.bz2 > /dev/null 2>&1 &
# ps auwx | grep curl
pgrep -l curl
pgrep -f curl
pgrep -fl curl
wait

exit
