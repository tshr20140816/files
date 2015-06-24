#!/bin/bash

source functions.sh
function010 stop
[ $? -eq 0 ] || exit

export HOME=${OPENSHIFT_DATA_DIR}
rm -f ${OPENSHIFT_DATA_DIR}/.distcc/lock/backoff*

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

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/ccache_passenger-install-apache2-module.tar.xz ./
if [ -f ccache_passenger-install-apache2-module.tar.xz ]; then
    rm -rf ccache
    tar Jxf ccache_passenger-install-apache2-module.tar.xz
    ccache -s
    export CC="ccache gcc"
    export CXX="ccache g++"
else
    tmp_string=$(echo ${DISTCC_HOSTS} | sed -e "s|/4:|/1:|g")
    export DISTCC_HOSTS="${tmp_string}"
    export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"
    export MAKEOPTS="-j6"
    # 32MB
    export RUBY_GC_MALLOC_LIMIT=33554432
fi
popd > /dev/null

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

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
if [ -f ccache_passenger-install-apache2-module.tar.xz ]; then
    ccache -s
    rm -f ccache_passenger-install-apache2-module.tar.xz
    rm -rf ${CCACHE_DIR}
    mkdir -p ${CCACHE_DIR}
fi
popd > /dev/null
touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
