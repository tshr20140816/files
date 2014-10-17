#!/bin/bash

set -x

while read LINE
do
    product=`echo $LINE | awk '{print $1}'`
    version=`echo $LINE | awk '{print $2}'`
    eval "$product"=$version
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 11 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** delegate *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/delegate${delegate_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` delegate tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz delegate${delegate_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/delegate${delegate_version} > /dev/null
echo `date +%Y/%m/%d" "%H:%M:%S` delegate make >> ${OPENSHIFT_LOG_DIR}/install.log
perl -pi -e 's/^ADMIN = undef$/ADMIN = admin\@rhcloud.local/g' src/Makefile
time make -j2 CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" 2>&1 | tee ${OPENSHIFT_LOG_DIR}/delegate.make.log
mkdir ${OPENSHIFT_DATA_DIR}/delegate/
cp src/delegated ${OPENSHIFT_DATA_DIR}/delegate/
# cp ${OPENSHIFT_DATA_DIR}/github/openshift/delegated.xz ./
# xz -dv delegated.xz
# mv ./delegated ${OPENSHIFT_DATA_DIR}/delegate/

# apache htdocs
mkdir -p ${OPENSHIFT_DATA_DIR}/apache/htdocs/delegate/icons
cp src/builtin/icons/ysato/*.* ${OPENSHIFT_DATA_DIR}/apache/htdocs/delegate/icons/
# */
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/delegate/ > /dev/null
cat << '__HEREDOC__' > P30080
-P__OPENSHIFT_DIY_IP__:30080
SERVER=http
ADMIN=admin@rhcloud.local
DGROOT=__OPENSHIFT_DATA_DIR__delegate
MOUNT="/mail/* pop://pop.mail.yahoo.co.jp:110/* noapop" 
FTOCL="/bin/sed -f __OPENSHIFT_DATA_DIR__delegate/filter.txt" 
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' P30080
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' P30080
cat << '__HEREDOC__' > filter.txt
s/http:..__OPENSHIFT_DIY_IP__:30080.-.builtin.icons.ysato/\/delegate\/icons/g
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' filter.txt
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm delegate${delegate_version}.tar.gz
rm -rf delegate${delegate_version}
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 11 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
