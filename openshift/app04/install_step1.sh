#!/bin/bash

distcc_version=3.1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2
tar jxf distcc-${distcc_version}.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
./configure --prefix=${OPENSHIFT_DATA_DIR}/distcc
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/distcc > /dev/null
touch ${OPENSHIFT_LOG_DIR}/distccd.log
./bin/distccd --daemon --listen ${OPENSHIFT_DIY_IP} --jobs 2 --port 33632 \
 --allow 0.0.0.0/0 --log-file=${OPENSHIFT_LOG_DIR}/distccd.log --verbose --log-stderr 
popd > /dev/null
