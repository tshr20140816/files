#!/bin/bash

set -x

while read LINE
do
  product=`echo $LINE | awk '{print $1}'`
  version=`echo $LINE | awk '{print $2}'`
  eval "$product"=$version
done < ${OPENSHIFT_TMP_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 10 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** webalizer *****

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/webalizer-${webalizer_version}-src.tgz ./

echo `date +%Y/%m/%d" "%H:%M:%S` webalizer tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz webalizer-${webalizer_version}-src.tgz
cd webalizer-${webalizer_version}
mv lang/webalizer_lang.japanese lang/webalizer_lang.japanese_euc
iconv -f euc-jp -t utf-8 lang/webalizer_lang.japanese_euc > lang/webalizer_lang.japanese

echo `date +%Y/%m/%d" "%H:%M:%S` webalizer configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/webalizer \
--mandir=${OPENSHIFT_DATA_DIR}/webalizer \
--with-language=japanese --enable-dns 2>&1 | tee ${OPENSHIFT_LOG_DIR}/webalizer.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` webalizer make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j2

echo `date +%Y/%m/%d" "%H:%M:%S` webalizer make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install

cd ${OPENSHIFT_DATA_DIR}/webalizer/etc
cp webalizer.conf.sample webalizer.conf
echo >> webalizer.conf
echo >> webalizer.conf
echo LogFile ${OPENSHIFT_DATA_DIR}/apache/logs/access_log >> webalizer.conf
echo OutputDir ${OPENSHIFT_DATA_DIR}/webalizer/www >> webalizer.conf
echo HostName ${OPENSHIFT_APP_DNS} >> webalizer.conf
echo UseHTTPS yes >> webalizer.conf

cd ${OPENSHIFT_TMP_DIR}
rm webalizer-${webalizer_version}-src.tgz
rm -rf webalizer-${webalizer_version}

# *** apache link ***

ln -s ${OPENSHIFT_DATA_DIR}/webalizer/www ${OPENSHIFT_DATA_DIR}/apache/htdocs/webalizer

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 10 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
