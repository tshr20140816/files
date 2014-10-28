#!/bin/bash

set -x

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 2 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** lynx *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/lynx2.8.7.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` lynx tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz lynx2.8.7.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}lynx2-8-7 > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` lynx configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/lynx 2>&1 | tee ${OPENSHIFT_LOG_DIR}/lynx.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` lynx make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j4

echo `date +%Y/%m/%d" "%H:%M:%S` lynx make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm lynx2.8.7.tar.gz
rm -rf lynx2-8-7
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 2 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
