#!/bin/bash

source functions.sh
function010 stop
[ $? -eq 0 ] || exit

# ***** passenger-install-apache2-module *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -f ccache.tar.xz
cp -f ${OPENSHIFT_DATA_DIR}/download_files/ccache_passenger.tar.xz ./ccache.tar.xz
ccache -z
if [ -f ccache.tar.xz ]; then
    rm -rf ccache
    time tar Jxf ccache.tar.xz
    rm -f ccache.tar.xz
else
    ccache -C
fi
popd > /dev/null

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)" 
export PATH=${OPENSHIFT_DATA_DIR}/apache/bin:$PATH
export HTTPD=${OPENSHIFT_DATA_DIR}/apache/bin/httpd
export BINDIR=${OPENSHIFT_DATA_DIR}/apache

time ${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module \
 --auto \
 --languages ruby \
 --apxs2-path ${OPENSHIFT_DATA_DIR}/apache/bin/apxs

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
ccache -s | tee -a ${OPENSHIFT_LOG_DIR}/install.log
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/is_make_ccache_data) = "yes" ]; then
    time tar Jcf ccache.tar.xz ccache
    mv -f ccache.tar.xz ${OPENSHIFT_DATA_DIR}/ccache_passenger.tar.xz
fi
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
