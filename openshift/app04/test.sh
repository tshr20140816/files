#!/bin/bash

echo "1024"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

# mkdir -p ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress
# pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress > /dev/null
# rm -f wordpress-4.4.2-ja.tar.gz
# wget https://ja.wordpress.org/wordpress-4.4.2-ja.tar.gz
# tar zxf wordpress-4.4.2-ja.tar.gz --strip-components=1
# rm -f wordpress-4.4.2-ja.tar.gz
# popd > /dev/null

# rm -f js_list.txt
# find ${OPENSHIFT_DATA_DIR} -name "*.js" -mindepth 2 -type f -print | grep wordpress | tee -a js_list.txt

# flag=0

# for target_file in $(cat js_list.txt)
# do
#   path=$(echo ${target_file} | sed -e "s|${OPENSHIFT_HOMEDIR}||g")
#   if [ $flag -eq 1 ]; then
#     echo ${path}
#     curl $(cat sv.txt) -F "file=@${target_file}" -F "suffix=${OPENSHIFT_APP_UUID}" -F "path=${path}" -o /dev/null 2>/dev/null
#   fi
#   if [ "app-root/data/apache/htdocs/wordpress/wp-includes/js/media-views.js" = ${path} ]; then
#     flag=1
#   fi
# done
# sort --help

# cat js_list.txt | sort -R

# sort --random-sort js_list.txt

while read LINE
do
    echo ${LINE}
done < (sort --random-sort js_list.txt | head -n 10)

exit
