#!/bin/bash

echo "$(date)" >> ${OPENSHIFT_LOG_DIR}/test.log

cd /tmp

# if [ ! -f pbzip2-1.1.12.tar.gz ]; then
#     wget https://launchpad.net/pbzip2/1.1/1.1.12/+download/pbzip2-1.1.12.tar.gz >> ${OPENSHIFT_LOG_DIR}/test.log 2>&1
# fi
# tar xfz pbzip2-1.1.12.tar.gz
# cd pbzip2-1.1.12
# time make -j4 >> ${OPENSHIFT_LOG_DIR}/test.log 2>&1
# ls -lang >> ${OPENSHIFT_LOG_DIR}/test.log 2>&1

# rm -f ccache.tar.xz
# wget https://files3-20150207.rhcloud.com/files/ccache.tar.xz >> ${OPENSHIFT_LOG_DIR}/test.log 2>&1

# tar Jxf ccache.tar.xz

# ls -lang >> ${OPENSHIFT_LOG_DIR}/test.log 2>&1

tar cf ccache.tar.bz2 --use-compress-program=/tmp/pbzip2 ccache

