#!/bin/bash

cd /tmp
wget https://distcc.googlecode.com/files/distcc-3.1.tar.bz2
tar jxf distcc-3.1.tar.bz2
cd distcc-3.1
./configure --prefix=${OPENSHIFT_DATA_DIR}/distcc
time make -j2
make install

cd ${OPENSHIFT_DATA_DIR}/distcc
./bin/distccd --daemon --listen ${OPENSHIFT_DIY_IP} --jobs 2 --port 33632 \
 --allow 0.0.0.0/0 --log-file=${OPENSHIFT_TMP_DIR}/distccd.log --verbose --log-stderr 
