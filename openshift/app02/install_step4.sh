#!/bin/bash

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

set -x

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 4 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** pcre *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/pcre-${pcre_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` pcre tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz pcre-${pcre_version}.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/pcre-${pcre_version} > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` pcre configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/pcre 2>&1 | tee ${OPENSHIFT_LOG_DIR}/pcre.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` pcre make >> ${OPENSHIFT_LOG_DIR}/install.log
time make 2>&1 | tee ${OPENSHIFT_LOG_DIR}/pcre.make.log

echo `date +%Y/%m/%d" "%H:%M:%S` pcre make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install 2>&1 | tee ${OPENSHIFT_LOG_DIR}/pcre.make.install.log
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm pcre-${pcre_version}.tar.gz
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 4 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
