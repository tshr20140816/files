#!/bin/bash

export TZ=JST-9
set -x

quota -s
oo-cgroup-read memory.usage_in_bytes
oo-cgroup-read memory.failcnt

cd /tmp
wget https://distcc.googlecode.com/files/distcc-3.1.tar.bz2
tar jxf distcc-3.1.tar.bz2
rm -f distcc-3.1.tar.bz2
cd distcc-3.1
./configure --prefix=${OPENSHIFT_DATA_DIR}/distcc \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man
time make -j4
make install

# export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
# export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
# export DISTCC_LOG=/dev/null
