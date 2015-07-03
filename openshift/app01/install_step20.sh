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
echo "shell syntax error count : $(wc -l ${OPENSHIFT_LOG_DIR}/shell_syntax_error.txt)" \
 | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# ***** delete files *****

rm -f ${OPENSHIFT_DATA_DIR}/download_files/*
pushd ${OPENSHIFT_DATA_DIR}/.gem/gems/bundler-* > /dev/null
rm -rf man
rm -rf lib/bundler/man
popd > /dev/null
pushd ${OPENSHIFT_DATA_DIR}/.gem/gems/passenger-* > /dev/null
rm -rf doc
rm -rf man
rm -f download_cache/nginx*
popd > /dev/null
find ${OPENSHIFT_DATA_DIR}/.gem -name '*.md' -type f -print0 | xargs -0i -t -P 4 -n 3 rm -f {}

# ***** strip *****

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
find ./ -name "*" -mindepth 2 -type f -print0 \
 | xargs -0i file {} \
 | grep -e "not stripped" \
 | grep -v -e "delegated" \
 | awk -F':' '{printf $1"\n"}' \
 > ${OPENSHIFT_TMP_DIR}/strip_starget.txt
echo "strip target count : $(wc -l ${OPENSHIFT_TMP_DIR}/strip_starget.txt)" \
 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# time cat ${OPENSHIFT_TMP_DIR}/strip_starget.txt | xargs -t -P 4 -n 3 strip --strip-all
# time cat ${OPENSHIFT_TMP_DIR}/strip_starget.txt | xargs -t -P 4 -n 3 strip --strip-debug
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
