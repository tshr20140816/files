#!/bin/bash

# rhc app create xxx diy-1.0 --server openshift.redhat.com

# http://www.ibm.com/developerworks/jp/linux/library/l-ccache/

set -x

export TZ=JST-9

cd /tmp

wget http://samba.org/ftp/ccache/ccache-3.2.1.tar.xz
tar Jxf  ccache-3.2.1.tar.xz
cd ccache
./configure --prefix=${OPENSHIFT_DATA_DIR}/ccache
time make -j4
make install

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"

cd /tmp

wget http://ftp.riken.jp/net/apache//httpd/httpd-2.2.29.tar.bz2
tar jxf httpd-2.2.29.tar.bz2
cd httpd
./configure --prefix=${OPENSHIFT_DATA_DIR}/apache
time make -j4

