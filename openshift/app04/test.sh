#!/bin/bash

echo "0924"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp
# cat sv.txt
# mv -f ${OPENSHIFT_DATA_DIR}js_list.txt ./
# cat js_list.txt
# rm -f js_list.txt
rm -f redmine-2.6.10.tar.gz
# wget http://www.redmine.org/releases/redmine-2.6.10.tar.gz
# cd ${OPENSHIFT_DATA_DIR}
# mv -f /tmp/redmine-2.6.10.tar.gz ./
# tar xfz redmine-2.6.10.tar.gz
# rm -f redmine-2.6.10.tar.gz

# rm -f js_list.txt
# find ${OPENSHIFT_DATA_DIR} -name "*.js" -mindepth 2 -type f -print | grep redmine | tee -a js_list.txt

ls -lang
flag=0

for target_file in $(cat js_list.txt)
do
  path=$(echo ${target_file} | sed -e "s|${OPENSHIFT_HOMEDIR}||g")
  if [ $flag -eq 1 ]; then
    echo ${path}
    curl $(cat sv.txt) -F "file=@${target_file}" -F "suffix=${OPENSHIFT_APP_UUID}" -F "path=${path}" -o /dev/null
  fi
  if [ "app-root/data/redmine-2.6.10/public/javascripts/jstoolbar/jstoolbar-textile.min.js" = ${path} ]; then
      flag=1
  fi
done

exit
