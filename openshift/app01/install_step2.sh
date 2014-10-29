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

mkdir -p ${OPENSHIFT_TMP_DIR}/lynx

pushd ${OPENSHIFT_TMP_DIR}lynx > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/lynx${lynx_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` lynx tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz lynx${lynx_version}.tar.gz --strip-components=1
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}lynx > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` lynx configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/lynx 2>&1 | tee ${OPENSHIFT_LOG_DIR}/lynx.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` lynx make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j4

echo `date +%Y/%m/%d" "%H:%M:%S` lynx make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm lynx${lynx_version}.tar.gz
rm -rf lynx
popd > /dev/null

# ***** vim *****

mkdir -p ${OPENSHIFT_TMP_DIR}/vim

pushd ${OPENSHIFT_TMP_DIR}lynx > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/vim-${vim_version}.tar.bz2 ./

echo `date +%Y/%m/%d" "%H:%M:%S` vim tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfj vim-${vim_version}.tar.bz2 --strip-components=1
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 2 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
