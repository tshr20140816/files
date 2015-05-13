#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** webalizer *****

rm -f ${OPENSHIFT_TMP_DIR}/webalizer-${webalizer_version}-src.tar.bz2
rm -rf ${OPENSHIFT_TMP_DIR}/webalizer-${webalizer_version}
rm -rf ${OPENSHIFT_DATA_DIR}/webalizer

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/webalizer-${webalizer_version}-src.tar.bz2 ./

echo "$(date +%Y/%m/%d" "%H:%M:%S) webalizer tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar jxf webalizer-${webalizer_version}-src.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/webalizer-${webalizer_version} > /dev/null
mv lang/webalizer_lang.japanese lang/webalizer_lang.japanese_euc
iconv -f euc-jp -t utf-8 lang/webalizer_lang.japanese_euc > lang/webalizer_lang.japanese

echo "$(date +%Y/%m/%d" "%H:%M:%S) webalizer configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_webalizer.log
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/webalizer \
--mandir=${OPENSHIFT_TMP_DIR}/man \
--docdir=${OPENSHIFT_TMP_DIR}/doc \
--with-language=japanese \
--enable-dns 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_webalizer.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) webalizer make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_webalizer.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_webalizer.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) webalizer make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_webalizer.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_webalizer.log
mv ${OPENSHIFT_LOG_DIR}/install_webalizer.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/webalizer/etc > /dev/null
# cp webalizer.conf.sample webalizer.conf
cat << '__HEREDOC__' > webalizer.conf
# PageType *
HistoryName webalizer.hist
Incremental yes
IncrementalName webalizer.current

# LogFile __OPENSHIFT_DATA_DIR__/apache/logs/access_log
OutputDir __OPENSHIFT_DATA_DIR__/webalizer/www
HostName __OPENSHIFT_APP_DNS__
UseHTTPS yes
CountryGraph no
CountryFlags no

HTMLHead <meta http-equiv="content-type" content="text/html; charset=utf-8">
HTMLHead <meta http-equiv="content-style-type" content="text/css">
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" webalizer.conf
sed -i -e "s|__OPENSHIFT_APP_DNS__|${OPENSHIFT_APP_DNS}|g" webalizer.conf
popd > /dev/null

mkdir ${OPENSHIFT_DATA_DIR}/webalizer/www

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm webalizer-${webalizer_version}-src.tar.bz2
rm -rf webalizer-${webalizer_version}
popd > /dev/null

# *** apache link ***

ln -s ${OPENSHIFT_DATA_DIR}/webalizer/www ${OPENSHIFT_DATA_DIR}/apache/htdocs/webalizer

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
