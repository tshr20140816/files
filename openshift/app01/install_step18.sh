#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** shell syntax check *****

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
find ${OPENSHIFT_DATA_DIR} -name *.sh -type f -print0 | xargs -0i bash -n {} \
 >> ${OPENSHIFT_LOG_DIR}/shell_syntax_error.log 2>&1
find ${OPENSHIFT_REPO_DIR}/.openshift/cron/ -name *.sh -type f -print0 | xargs -0i bash -n {} \
 >> ${OPENSHIFT_LOG_DIR}/shell_syntax_error.log 2>&1
popd > /dev/null

# ***** delete files *****

rm -f ${OPENSHIFT_DATA_DIR}/download_files/*

# ***** ccache compress *****

# pushd ${OPENSHIFT_TMP_DIR} > /dev/null
# ccache -s | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# rm -f ccache.tar.xz
# tar Jcf ccache.tar.xz ccache
# ccache -C
# # ファイルサイズが大きいのでこっちからアップロードではなく向こうからダウンロードしてもらう
# mv -f ccache.tar.xz ${OPENSHIFT_DATA_DIR}/apache/htdocs/
# password=$(cat ${OPENSHIFT_DATA_DIR}/params/ccache_upload_password)
# wget --post-data="\"password=${password}&host_name=${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}\"" \
#  ${mirror_server}/ccache_file_upload_counter.php
# popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
