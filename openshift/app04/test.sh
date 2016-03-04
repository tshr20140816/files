#!/bin/bash

echo "1431"

set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log

cd /tmp

ls -lang

# wget https://tt-rss.org/gitlab/fox/tt-rss/repository/archive.zip?ref=master -O ttrss_archive.zip
# wget http://www.kokkonen.net/tjko/src/jpegoptim-1.4.3.tar.gz
# wget http://downloads.sourceforge.net/project/optipng/OptiPNG/optipng-0.7.5/optipng-0.7.5.tar.gz
rm -f compiler-latest.zip*
# wget http://dl.google.com/closure-compiler/compiler-latest.zip

# cp ./ttrss_archive.zip ${OPENSHIFT_DATA_DIR}/

# cd ${OPENSHIFT_DATA_DIR}
# unzip ttrss_archive.zip

# ls -lang

cd /tmp

# unzip compiler-latest.zip

counter=1
for file_name in $(find ${OPENSHIFT_DATA_DIR} -name "*.js" -type f -print)
do
    echo ${counter}
    time java -jar ./compiler.jar --summary_detail_level 3 --js ${file_name} --js_output_file ./$(basename "${file_name}").${RANDOM} &
    counter=$((${counter}+1))
    while :
    do
        usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
        echo ${usage_in_bytes}
        if [ ${usage_in_bytes} > $((300 * (10**6))) ]; then
            sleep 5s
        else
            break
        fi
    done
done

# time java -jar ./compiler.jar --summary_detail_level 3 --js ${OPENSHIFT_DATA_DIR}/tt-rss.git/js/prefs.js --js_output_file ./prefs.js &

wait

exit
