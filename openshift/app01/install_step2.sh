#!/bin/bash

wget --spider `cat ${OPENSHIFT_DATA_DIR}/web_beacon_server`dummy?server=${OPENSHIFT_GEAR_DNS}&part=`basename $0 .sh` >/dev/null 2>&1

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

set -x

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 2 Start | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# ***** lynx *****

mkdir -p ${OPENSHIFT_TMP_DIR}/lynx

pushd ${OPENSHIFT_TMP_DIR}lynx > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/lynx${lynx_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` lynx tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz lynx${lynx_version}.tar.gz --strip-components=1
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}lynx > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` lynx configure | tee -a ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/lynx 2>&1 | tee ${OPENSHIFT_LOG_DIR}/lynx.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` lynx make | tee -a ${OPENSHIFT_LOG_DIR}/install.log
time make -j4 2>&1 | tee ${OPENSHIFT_LOG_DIR}/lynx.make.log

echo `date +%Y/%m/%d" "%H:%M:%S` lynx make install | tee -a ${OPENSHIFT_LOG_DIR}/install.log
make install 2>&1 | tee ${OPENSHIFT_LOG_DIR}/lynx.make.install.log
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -rf lynx
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 2 Finish | tee -a ${OPENSHIFT_LOG_DIR}/install.log
