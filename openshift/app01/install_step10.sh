#!/bin/bash

source functions.sh
function010 stop
[ $? -eq 0 ] || exit

export HOME=${OPENSHIFT_DATA_DIR}
rm -f ${OPENSHIFT_DATA_DIR}/.distcc/lock/backoff*

cat ${OPENSHIFT_TMP_DIR}/user_fqdn.txt | tee -a ${OPENSHIFT_LOG_DIR}/install.log
while read LINE
do
    user_fqdn=$(echo "${LINE}")
    ssh -24n -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} pwd 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
done < ${OPENSHIFT_TMP_DIR}/user_fqdn.txt

# ***** passenger-install-apache2-module *****
# https://github.com/phusion/passenger/blob/master/bin/passenger-install-apache2-module

# *** env ***

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)" 
export PATH=${OPENSHIFT_DATA_DIR}/apache/bin:$PATH
# export HTTPD=${OPENSHIFT_DATA_DIR}/apache/bin/httpd
# export BINDIR=${OPENSHIFT_DATA_DIR}/apache

tmp_string=$(echo ${DISTCC_HOSTS} | sed -e "s|/2:|/1:|g")
export DISTCC_HOSTS="${tmp_string}"
export MAKEOPTS="-j6"

# *** install ***

${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module --help | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# export EXTRA_CFLAGS="${CFLAGS}"
# export EXTRA_CXXFLAGS="${CXXFLAGS}"

# time CC="distcc gcc" CXX="distcc g++" ${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module \
#  --auto \
#  --languages ruby \
#  --apxs2-path ${OPENSHIFT_DATA_DIR}/apache/bin/apxs

time ${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module \
 --auto \
 --languages ruby \
 --apxs2-path ${OPENSHIFT_DATA_DIR}/apache/bin/apxs

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
