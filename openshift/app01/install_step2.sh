#!/bin/bash

source functions.sh
function010 && exit

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

# echo `date +%Y/%m/%d" "%H:%M:%S` dbench configure | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# echo `date +%Y/%m/%d" "%H:%M:%S` '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_dbench.log
# CFLAGS="-O2 -march=native -pipe" CXXFLAGS="-O2 -march=native -pipe" \
# ./configure \
# --mandir=/tmp/man \
# --docdir=/tmp/doc \
# --prefix=${OPENSHIFT_DATA_DIR}/dbench 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_dbench.log

# echo `date +%Y/%m/%d" "%H:%M:%S` dbench make | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_dbench.log
# time make -j4 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_dbench.log

# echo `date +%Y/%m/%d" "%H:%M:%S` dbench make install | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_dbench.log
# make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_dbench.log
# popd > /dev/null

rm -rf ${OPENSHIFT_TMP_DIR}/dbench

# *** run dbench ***

# processor_count=$(cat /proc/cpuinfo | grep processor | wc -l)
# ${OPENSHIFT_DATA_DIR}/dbench/dbench 4 2>&1 | tee ${OPENSHIFT_LOG_DIR}/dbench_4.log
# if [ ${processor_count} != 4 ]; then
#     ${OPENSHIFT_DATA_DIR}/dbench/dbench ${processor_count} 2>&1 | tee ${OPENSHIFT_LOG_DIR}/dbench_${processor_count}.log
# fi
# # cat ${OPENSHIFT_LOG_DIR}/dbench.log | grep Throughput

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
