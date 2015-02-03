#!/bin/bash

wget --spider `cat ${OPENSHIFT_DATA_DIR}/web_beacon_server`dummy?server=${OPENSHIFT_GEAR_DNS}\&part=`basename $0 .sh` >/dev/null 2>&1

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
echo `date +%Y/%m/%d" "%H:%M:%S` ***** configure ***** $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_fping.log

CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/fping 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_fping.log

echo `date +%Y/%m/%d" "%H:%M:%S` fping make | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` ***** make ***** $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_fping.log

time make -j4 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_fping.log

echo `date +%Y/%m/%d" "%H:%M:%S` fping make install | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` ***** make install ***** $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_fping.log

make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_fping.log
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -rf fping-${fping_version}
popd > /dev/null

# ***** pcre *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/pcre-${pcre_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` pcre tar >> ${OPENSHIFT_LOG_DIR}/install.log

tar xfz pcre-${pcre_version}.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/pcre-${pcre_version} > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` pcre configure >> ${OPENSHIFT_LOG_DIR}/install.log
echo `date +%Y/%m/%d" "%H:%M:%S` ***** configure ***** $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_pcre.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/pcre 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_pcre.log

echo `date +%Y/%m/%d" "%H:%M:%S` pcre make >> ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` ***** make ***** $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_pcre.log
time make -j4 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_pcre.log

echo `date +%Y/%m/%d" "%H:%M:%S` pcre make install >> ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` ***** make install ***** $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_pcre.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_pcre.log
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm pcre-${pcre_version}.tar.gz
popd > /dev/null

# ***** c-ares *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/c-ares-${c-ares_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` pcre tar >> ${OPENSHIFT_LOG_DIR}/install.log

tar xfz c-ares-${c-ares_version}.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/c-ares-${c-ares_version} > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` c-ares configure >> ${OPENSHIFT_LOG_DIR}/install.log
echo `date +%Y/%m/%d" "%H:%M:%S` ***** configure ***** $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_c-ares.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/c-ares 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_c-ares.log

echo `date +%Y/%m/%d" "%H:%M:%S` c-ares make >> ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` ***** make ***** $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_c-ares.log
time make -j4 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_c-ares.log

echo `date +%Y/%m/%d" "%H:%M:%S` c-ares make install >> ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` ***** make install ***** $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_c-ares.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_c-ares.log
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm c-ares-${c-ares_version}.tar.gz
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
--pcrelib=${OPENSHIFT_DATA_DIR}/pcre \
--fping=${OPENSHIFT_DATA_DIR}/fping \
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
