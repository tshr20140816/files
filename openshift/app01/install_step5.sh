#!/bin/bash

wget --spider `cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server`dummy?server=${OPENSHIFT_GEAR_DNS}\&part=`basename $0 .sh` >/dev/null 2>&1

set -x

export TZ=JST-9

pushd ${OPENSHIFT_DATA_DIR}/install_check_point > /dev/null
if [ -f `basename $0`.ok ]; then
    echo `date +%Y/%m/%d" "%H:%M:%S` Install Skip `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    exit
fi
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install Start `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# メモリが厳しいのでアプリケーションを止めて行う
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

touch ${OPENSHIFT_DATA_DIR}/install_check_point/`basename $0`.ok

/usr/bin/gear start

echo `date +%Y/%m/%d" "%H:%M:%S` Install Finish `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
