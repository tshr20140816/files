#!/bin/bash

source functions.sh
function010 stop
[ $? -eq 0 ] || exit

export HOME=${OPENSHIFT_DATA_DIR}
rm -f ${OPENSHIFT_DATA_DIR}/.distcc/lock/backoff*

# ***** passenger-install-apache2-module *****
# https://github.com/phusion/passenger/blob/master/bin/passenger-install-apache2-module

# *** log ***

export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache_passenger-install-apache2-module.log
export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc_passenger-install-apache2-module.log

touch ${CCACHE_LOGFILE}
touch ${DISTCC_LOG}
tail -f ${CCACHE_LOGFILE} &
pid_CCACHE_LOGFILE=$!
tail -f ${DISTCC_LOG} &
pid_DISTCC_LOG=$!

# *** patch ***

pushd ${OPENSHIFT_DATA_DIR}/.gem/gems/passenger-* > /dev/null
sed -i -e 's|make -j2|make -j6|g' build/common_library.rb
# sed -i -e 's|make |time make |g' build/common_library.rb
sed -i -e 's|cflags = "#{EXTRA_CFLAGS} -w"|cflags = "-O2 -w"|g' build/common_library.rb
popd > /dev/null

# *** env ***

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
[ $(echo $PATH | grep -c ${OPENSHIFT_DATA_DIR}/.rbenv/bin) -eq 0 ] && export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
[ $(echo $PATH | grep -c ${OPENSHIFT_DATA_DIR}/.gem/bin) -eq 0 ] && export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)" 
[ $(echo $PATH | grep -c ${OPENSHIFT_DATA_DIR}/apache/bin) -eq 0 ] && export PATH=${OPENSHIFT_DATA_DIR}/apache/bin:$PATH
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

kill ${pid_CCACHE_LOGFILE}
kill ${pid_DISTCC_LOG}

mv ${OPENSHIFT_LOG_DIR}/ccache_passenger-install-apache2-module.log ${OPENSHIFT_LOG_DIR}/install/
mv ${OPENSHIFT_LOG_DIR}/distcc_passenger-install-apache2-module.log ${OPENSHIFT_LOG_DIR}/install/

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
