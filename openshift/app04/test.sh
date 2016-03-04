#!/bin/bash

echo "1406"

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

# for file_name in $(find ${OPENSHIFT_DATA_DIR} -name "*.jpg" -type f -print)
# do
    # time java -jar ./compiler.jar --summary_detail_level 3 --js ${file_name} --js_output_file ./result.js
    # wc -c < ${file_name}
    # wc -c < ./result.js
    # ls -lang ${file_name}
# done

time java -jar ./compiler.jar --summary_detail_level 3 --js ${OPENSHIFT_DATA_DIR}/tt-rss.git/js/prefs.js --js_output_file ./prefs.js &
time java -jar ./compiler.jar --summary_detail_level 3 --js ${OPENSHIFT_DATA_DIR}/tt-rss.git/js/viewfeed.js --js_output_file ./viewfeed.js &
time java -jar ./compiler.jar --summary_detail_level 3 --js ${OPENSHIFT_DATA_DIR}/tt-rss.git/lib/CheckBoxTree.js --js_output_file ./CheckBoxTree.js &
time java -jar ./compiler.jar --summary_detail_level 3 --js ${OPENSHIFT_DATA_DIR}/tt-rss.git/lib/dijit/BackgroundIframe.js --js_output_file ./BackgroundIframe.js &
time java -jar ./compiler.jar --summary_detail_level 3 --js ${OPENSHIFT_DATA_DIR}/tt-rss.git/lib/dijit/Calendar.js --js_output_file ./Calendar.js &

wait

exit
