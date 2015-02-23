#!/bin/bash

source functions.sh
function010
$? && exit

# ***** baikal *****

rm -rf ${OPENSHIFT_DATA_DIR}/apache/htdocs/baikal-regular
rm -rf ${OPENSHIFT_DATA_DIR}/apache/htdocs/baikal

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/baikal-regular-${baikal_version}.tgz ./
echo $(date +%Y/%m/%d" "%H:%M:%S) baikal tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz baikal-regular-${baikal_version}.tgz
mv baikal-regular baikal
popd > /dev/null

rm ${OPENSHIFT_DATA_DIR}/apache/htdocs/baikal-regular-${baikal_version}.tgz

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo $(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename $0) | tee -a ${OPENSHIFT_LOG_DIR}/install.log
