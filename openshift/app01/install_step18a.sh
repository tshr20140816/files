#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** cadaver *****

rm -f ${OPENSHIFT_TMP_DIR}/cadaver-${cadaver_version}.tar.gz
rm -rf ${OPENSHIFT_TMP_DIR}/cadaver-${cadaver_version}
rm -rf ${OPENSHIFT_DATA_DIR}/cadaver

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/cadaver-${cadaver_version}.tar.gz ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar zxf cadaver-${cadaver_version}.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/cadaver-${cadaver_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_cadaver.log

./configure \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --with-ssl=openssl \
 --prefix=${OPENSHIFT_DATA_DIR}/cadaver 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_cadaver.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_cadaver.log

time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_cadaver.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_cadaver.log

make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_cadaver.log
mv ${OPENSHIFT_LOG_DIR}/install_cadaver.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

rm -f ${OPENSHIFT_TMP_DIR}/cadaver-${cadaver_version}.tar.gz
rm -rf ${OPENSHIFT_TMP_DIR}/cadaver-${cadaver_version}

hidrive_account=$(cat ${OPENSHIFT_DATA_DIR}/params/hidrive_account)
hidrive_password=$(cat ${OPENSHIFT_DATA_DIR}/params/hidrive_password)

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
cat << '__HEREDOC__' > .netrc
machine https://webdav.hidrive.strato.com/ login __HIDRIVE_ACCOUNT__ password __HIDRIVE_PASSWORD__
__HEREDOC__
sed -i -e "s|__HIDRIVE_ACCOUNT__|${hidrive_account}|g" .netrc
sed -i -e "s|__HIDRIVE_PASSWORD__|${hidrive_password}|g" .netrc
chmod 600 .netrc
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
