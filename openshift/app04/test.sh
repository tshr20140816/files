#!/bin/bash

echo "1010"

# set -x

cd /tmp

rm -rf jpegoptim
rm -rf jpegoptim-1.4.3
rm -rf optipng
rm -rf optipng-0.7.5
rm -f result.txt
rm -f test2016029.txt

ls -lang >> ${OPENSHIFT_LOG_DIR}/test.log

cd ${OPENSHIFT_DATA_DIR}

rm -rf sphinx

ls -lang >> ${OPENSHIFT_LOG_DIR}/test.log


exit
