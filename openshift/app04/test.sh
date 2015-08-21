#!/bin/bash

set -x

quota -s

cd /tmp

export PATH="${OPENSHIFT_TMP_DIR}/gcc/bin:$PATH"
export LD_LIBRARY_PATH="${OPENSHIFT_TMP_DIR}/gcc/lib64:$LD_LIBRARY_PATH"
export CC=gcc-493
export CXX=gcc-493
export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

gcc-493 --version

rm -f httpd-2.2.31.tar.bz2*
wget https://files3-20150207.rhcloud.com/files/httpd-2.2.31.tar.bz2

tar jxf httpd-2.2.31.tar.bz2

cd httpd-2.2.31

./configure --help
time ./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/apache \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --disable-imagemap \
 --disable-status \
 --disable-userdir \
 --disable-include \
 --disable-authz-groupfile \
 --enable-mods-shared='all proxy'

time make -j4

cd /tmp

rm -rf httpd-2.2.31
