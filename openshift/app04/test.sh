#!/bin/bash

echo "1033"

set -x

cd /tmp

wget https://tt-rss.org/gitlab/fox/tt-rss/repository/archive.zip?ref=master -O ttrss_archive.zip
# wget http://www.kokkonen.net/tjko/src/jpegoptim-1.4.3.tar.gz
# wget http://downloads.sourceforge.net/project/optipng/OptiPNG/optipng-0.7.5/optipng-0.7.5.tar.gz
wget http://closure-compiler.googlecode.com/files/compiler-latest.zip

cp ./ttrss_archive.zip ${OPENSHIFT_DATA_DIR}/

cd ${OPENSHIFT_DATA_DIR}
unzip ttrss_archive.zip

ls -lang

cd /tmp

unzip compiler-latest.zip

for file_name in $(find ${OPENSHIFT_DATA_DIR} -name "*.js" -type f -print)
do
    time java -jar ./compiler.jar --summary_detail_level 3 --js ${file_name} --js_output_file ./result.js
done

exit
