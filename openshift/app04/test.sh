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

rm -f ccache.tar.bz2
rm -f ccache9.tar.bz2
rm -f ccache9_200.tar.bz2
rm -f ccache9_300.tar.bz2
# time tar cf ccache.tar.bz2 --use-compress-program=/tmp/pbzip2-1.1.12/pbzip2 ccache 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/test.log
# time tar -c ccache | /tmp/pbzip2-1.1.12/pbzip2 --best -m200 -p4 -z > ccache9_200.tar.bz2 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/test.log

wget http://tukaani.org/xz/xz-5.2.1.tar.gz
tar xfz xz-5.2.1.tar.gz
cd xz-5.2.1
ls -lang >> ${OPENSHIFT_LOG_DIR}/test.log 2>&1

rm -rf pixz-1.0.2
# wget http://downloads.sourceforge.net/project/pixz/pixz-1.0.2.tgz
# tar xfz pixz-1.0.2.tgz
# cd pixz-1.0.2
# time make -j4 >> ${OPENSHIFT_LOG_DIR}/test.log 2>&1
# ls -lang >> ${OPENSHIFT_LOG_DIR}/test.log 2>&1

cd /tmp
ls -lang >> ${OPENSHIFT_LOG_DIR}/test.log 2>&1
