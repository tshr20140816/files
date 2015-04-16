#!/bin/bash

source functions.sh
function010 stop
[ $? -eq 0 ] || exit

# ***** passenger-install-apache2-module *****

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)" 
export PATH=${OPENSHIFT_DATA_DIR}/apache/bin:$PATH
export HTTPD=${OPENSHIFT_DATA_DIR}/apache/bin/httpd
export BINDIR=${OPENSHIFT_DATA_DIR}/apache

time CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer" CXXFLAGS="-O2 -march=native -pipe" \
CC="ccache gcc" CXX="ccache g++" \
${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module \
--auto \
--languages ruby \
--apxs2-path ${OPENSHIFT_DATA_DIR}/apache/bin/apxs

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
