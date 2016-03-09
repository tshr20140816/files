#!/bin/bash

echo "1810"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

# rm -f test.php
# wget https://github.com/tshr20140816/files/raw/master/openshift/app04/test.php

# cp -f ./test.php ${OPENSHIFT_REPO_DIR}/

ls -lang

mkdir temp1
cd temp1
rm -f FeedTree.js
wget https://woo-20140818.rhcloud.com/ttrss/js/FeedTree.js
# js_code=$(cat ./FeedTree.js)
ruby -r uri -ne 'puts URI.escape $_.chomp' < ./FeedTree.js | tr "\n" " " | sed 's/ /%0D%0A/g'
# echo ${js_code}
# php -r 'echo urlencode("$js_code");'
# js_code=$(php -r 'echo urlencode("$js_code");')
# js_code=$(php -r "echo urlencode(\"$js_code\");")
# echo "${js_code}"
# wget --post-data="suffix=$$&js_code=2" --content-disposition https://tenv-20150605.rhcloud.com/test.php 
cd ..
rm -rf temp1

exit
