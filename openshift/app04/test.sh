#!/bin/bash

echo "1345"

set -x

quota -s

cd /tmp

rm ${OPENSHIFT_REPO_DIR}test.ics
rm ${OPENSHIFT_REPO_DIR}test.xml


curl --digest -u tshrapp9:$(date +%Y%m%d%H) \
 -F "url=https://woo-20140818.rhcloud.com/" \
 https://tshrapp9.appspot.com/createwebcroninformation

exit

