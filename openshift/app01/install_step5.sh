#!/bin/bash

set -x

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 5 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

#ctl_all stop
/usr/bin/gear stop

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH" 
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH" 
eval "$(rbenv init -)" 
export APXS2=${OPENSHIFT_DATA_DIR}/apache/bin/apxs
export PATH=${OPENSHIFT_DATA_DIR}/apache/bin:$PATH
export HTTPD=${OPENSHIFT_DATA_DIR}/apache/bin/httpd
export BINDIR=${OPENSHIFT_DATA_DIR}/apache

time CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module --auto

#ctl_all restart
/usr/bin/gear start

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 5 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
