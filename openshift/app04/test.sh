#!/bin/bash

echo "1005"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

# pushd  ${OPENSHIFT_DATA_DIR}/apache/htdocs
# rm -f ttrss_archive.zip
# wget https://tt-rss.org/gitlab/fox/tt-rss/repository/archive.zip?ref=master -O ttrss_archive.zip
# unzip ttrss_archive.zip
# mv tt-rss.git ttrss
# rm -f ttrss_archive.zip
# popd

# rm -f js_list.txt
# find ${OPENSHIFT_DATA_DIR} -name "*.js" -type f -print | grep ttrss | tee -a js_list.txt

# cat js_list.txt

flag=0

for target_file in $(cat js_list.txt)
do
  path=$(echo ${target_file} | sed -e "s|${OPENSHIFT_HOMEDIR}||g")
  if [ $flag -eq 1 ]; then
    echo ${path}
    curl $(cat sv.txt) -F "file=@${target_file}" -F "suffix=${OPENSHIFT_APP_UUID}" -F "path=${path}" -o /dev/null 2>/dev/null
  fi
  if [ "app-root/data/apache/htdocs/ttrss/lib/dojo/NodeList-traverse.js" = ${path} ]; then
    flag=1
  fi
done

exit
