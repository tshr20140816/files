#!/bin/bash

wget --spider `cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server`dummy?server=${OPENSHIFT_GEAR_DNS}\&part=`basename $0 .sh` >/dev/null 2>&1

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

set -x

export TZ=JST-9

pushd ${OPENSHIFT_DATA_DIR}/install_check_point > /dev/null
if [ -f `basename $0`.ok ]; then
    echo `date +%Y/%m/%d" "%H:%M:%S` Install Skip `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    exit
fi
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install Start `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# ***** dbench *****

rm -rf ${OPENSHIFT_TMP_DIR}/dbench
rm -rf ${OPENSHIFT_DATA_DIR}/dbench

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
echo `date +%Y/%m/%d" "%H:%M:%S` dbench git pull | tee -a ${OPENSHIFT_LOG_DIR}/install.log
git clone git://git.samba.org/sahlberg/dbench.git dbench
git pull
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/dbench > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` dbench autogen | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `date +%Y/%m/%d" "%H:%M:%S` '***** autogen *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_dbench.log
./autogen.sh 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_dbench.log

echo `date +%Y/%m/%d" "%H:%M:%S` dbench configure | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `date +%Y/%m/%d" "%H:%M:%S` '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_dbench.log
CFLAGS="-O2 -march=native -pipe" CXXFLAGS="-O2 -march=native -pipe" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/dbench 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_dbench.log

echo `date +%Y/%m/%d" "%H:%M:%S` dbench make | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_dbench.log
time make -j4 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_dbench.log

echo `date +%Y/%m/%d" "%H:%M:%S` dbench make install | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_dbench.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_dbench.log
popd > /dev/null

rm -rf ${OPENSHIFT_TMP_DIR}/dbench

# *** run dbench ***

${OPENSHIFT_DATA_DIR}/dbench/dbench 4 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/dbench.log

# TODO
# UnixBench
# SysBench
# Phoronix Test Suite

# ***** lynx *****

rm -rf ${OPENSHIFT_TMP_DIR}/lynx
rm -rf ${OPENSHIFT_DATA_DIR}/lynx
mkdir -p ${OPENSHIFT_TMP_DIR}/lynx

pushd ${OPENSHIFT_TMP_DIR}lynx > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/lynx${lynx_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` lynx tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz lynx${lynx_version}.tar.gz --strip-components=1
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}lynx > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` lynx configure | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `date +%Y/%m/%d" "%H:%M:%S` '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_lynx.log
CFLAGS="-O2 -march=native -pipe" CXXFLAGS="-O2 -march=native -pipe" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/lynx 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_lynx.log

echo `date +%Y/%m/%d" "%H:%M:%S` lynx make | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_lynx.log
time make -j4 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_lynx.log

echo `date +%Y/%m/%d" "%H:%M:%S` lynx make install | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_lynx.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_lynx.log
popd > /dev/null

rm -rf ${OPENSHIFT_TMP_DIR}/lynx

touch ${OPENSHIFT_DATA_DIR}/install_check_point/`basename $0`.ok

echo `date +%Y/%m/%d" "%H:%M:%S` Install Finish `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
