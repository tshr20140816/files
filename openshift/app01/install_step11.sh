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

# ***** webalizer *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/webalizer-${webalizer_version}-src.tar.bz2 ./

echo `date +%Y/%m/%d" "%H:%M:%S` webalizer tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar jxf webalizer-${webalizer_version}-src.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/webalizer-${webalizer_version} > /dev/null
mv lang/webalizer_lang.japanese lang/webalizer_lang.japanese_euc
iconv -f euc-jp -t utf-8 lang/webalizer_lang.japanese_euc > lang/webalizer_lang.japanese

echo `date +%Y/%m/%d" "%H:%M:%S` webalizer configure | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `date +%Y/%m/%d" "%H:%M:%S` '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_webalizer.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/webalizer \
--mandir=/tmp/man \
--with-language=japanese \
--enable-dns 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_webalizer.log

echo `date +%Y/%m/%d" "%H:%M:%S` webalizer make | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_webalizer.log
time make -j4 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_webalizer.log

echo `date +%Y/%m/%d" "%H:%M:%S` webalizer make install | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_webalizer.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_webalizer.log
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/webalizer/etc > /dev/null
cp webalizer.conf.sample webalizer.conf
echo >> webalizer.conf
echo >> webalizer.conf
echo LogFile ${OPENSHIFT_DATA_DIR}/apache/logs/access_log >> webalizer.conf
echo OutputDir ${OPENSHIFT_DATA_DIR}/webalizer/www >> webalizer.conf
echo HostName ${OPENSHIFT_APP_DNS} >> webalizer.conf
echo UseHTTPS yes >> webalizer.conf
popd > /dev/null

mkdir ${OPENSHIFT_DATA_DIR}/webalizer/www

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm webalizer-${webalizer_version}-src.tar.bz2
rm -rf webalizer-${webalizer_version}
popd > /dev/null

# *** apache link ***

ln -s ${OPENSHIFT_DATA_DIR}/webalizer/www ${OPENSHIFT_DATA_DIR}/apache/htdocs/webalizer

touch ${OPENSHIFT_DATA_DIR}/install_check_point/`basename $0`.ok

echo `date +%Y/%m/%d" "%H:%M:%S` Install Finish `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
