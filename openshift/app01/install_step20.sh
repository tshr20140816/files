#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** ssh master connection kill *****

for line in $(cat ${OPENSHIFT_DATA_DIR}/params/user_fqdn.txt)
do
    user_fqdn=$(echo "${line}")
    ssh -n -O check -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    ssh -n -O exit -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    ssh -n -O check -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
done

# ***** shell syntax check *****

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
find ${OPENSHIFT_DATA_DIR} -name *.sh -type f -print0 | xargs -0i bash -n {} \
 >> ${OPENSHIFT_LOG_DIR}/shell_syntax_error.log 2>&1
find ${OPENSHIFT_REPO_DIR}/.openshift/cron/ -name *.sh -type f -print0 | xargs -0i bash -n {} \
 >> ${OPENSHIFT_LOG_DIR}/shell_syntax_error.log 2>&1
popd > /dev/null

# ***** delete files *****

rm -f ${OPENSHIFT_DATA_DIR}/download_files/*

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
