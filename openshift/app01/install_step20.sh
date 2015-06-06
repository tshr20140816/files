#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** ssh master connection kill *****

for line in $(cat ${OPENSHIFT_DATA_DIR}/params/user_fqdn.txt)
do
    user_fqdn=$(echo "${line}")
    # ssh -O check -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    ssh -O exit -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    # ssh -O check -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
done

mv -f ${OPENSHIFT_LOG_DIR}/distcc_ssh.log ${OPENSHIFT_LOG_DIR}/install

# ***** shell syntax check *****

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
find ${OPENSHIFT_DATA_DIR} -name *.sh -type f -print0 | xargs -0i bash -n {} \
 >> ${OPENSHIFT_LOG_DIR}/shell_syntax_error.log 2>&1
find ${OPENSHIFT_REPO_DIR}/.openshift/cron/ -name *.sh -type f -print0 | xargs -0i bash -n {} \
 >> ${OPENSHIFT_LOG_DIR}/shell_syntax_error.log 2>&1
popd > /dev/null

# ***** delete files *****

rm -f ${OPENSHIFT_DATA_DIR}/download_files/*

# ***** strip *****

find ${OPENSHIFT_DATA_DIR}/ -name "*" -type f -print0 \
 | xargs -0i file {} \
 | grep -e "not stripped" \
 | grep -v -e "delegated" \
 | awk -F':' '{printf $1"\n"}' \
 | tee ${OPENSHIFT_TMP_DIR}/strip_starget.txt
wc -l ${OPENSHIFT_TMP_DIR}/strip_starget.txt | tee -a ${OPENSHIFT_LOG_DIR}/install.log
cat ${OPENSHIFT_TMP_DIR}/strip_starget.txt
for file_name in $(cat ${OPENSHIFT_TMP_DIR}/strip_starget.txt)
do
    strip --strip-all ${file_name} &
done
wait

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
