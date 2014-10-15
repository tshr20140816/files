#!/bin/bash

set -x

while read LINE
do
    product=`echo $LINE | awk '{print $1}'`
    version=`echo $LINE | awk '{print $2}'`
    eval "$product"=$version
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 13 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** Tcl *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/tcl${tcl_version}-src.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` Tcl tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz tcl${tcl_version}-src.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/tcl${tcl_version}/unix > /dev/null
echo `date +%Y/%m/%d" "%H:%M:%S` Tcl configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/tcl 2>&1 | tee ${OPENSHIFT_LOG_DIR}/tcl.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` Tcl make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j4

echo `date +%Y/%m/%d" "%H:%M:%S` Tcl make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm tcl${tcl_version}-src.tar.gz
# TODO
# rm -rf tcl${tcl_version}
popd > /dev/null

# ***** Expect *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/expect${expect_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` Expect tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz expect${expect_version}.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/expect${expect_version}/unix > /dev/null
echo `date +%Y/%m/%d" "%H:%M:%S` Expect configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/expect 2>&1 | tee ${OPENSHIFT_LOG_DIR}/expect.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` Expect make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j4

echo `date +%Y/%m/%d" "%H:%M:%S` Expect make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm expect${expect_version}.tar.gz
rm -rf expect${expect_version}
popd > /dev/null

# ***** rhc *****

# *** install ***

gem install rhc --no-rdoc --no-ri --verbose

# *** setup ***

# TODO
# rhc setup

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 13 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
