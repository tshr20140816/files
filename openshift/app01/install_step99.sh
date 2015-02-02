#!/bin/bash

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

set -x

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 99 Start | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# ***** fping *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/fping-${fping_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` fping tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz fping-${fping_version}.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}fping-${fping_version} > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` fping configure | tee -a ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/fping 2>&1 | tee ${OPENSHIFT_LOG_DIR}/fping.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` fping make | tee -a ${OPENSHIFT_LOG_DIR}/install.log
time make -j4

echo `date +%Y/%m/%d" "%H:%M:%S` fping make install | tee -a ${OPENSHIFT_LOG_DIR}/install.log
make install
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -rf fping-${fping_version}
popd > /dev/null

# ***** xymon *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/xymon-${xymon_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` xymon tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz xymon-${xymon_version}.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}xymon-${xymon_version} > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` xymon configure | tee -a ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/xymon 2>&1 | tee ${OPENSHIFT_LOG_DIR}/xymon.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` xymon make | tee -a ${OPENSHIFT_LOG_DIR}/install.log
time make -j4

echo `date +%Y/%m/%d" "%H:%M:%S` xymon make install | tee -a ${OPENSHIFT_LOG_DIR}/install.log
make install
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -rf xymon-${xymon_version}
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 99 Finish | tee -a ${OPENSHIFT_LOG_DIR}/install.log
