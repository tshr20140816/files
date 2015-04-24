#!/bin/bash

set -x

# configure 及び make の引数は全て貰う
# configure の必要有無のフラグ
# tar x 後のディレクトリ
# configure のディレクトリ

export target_data_dir='xxx' # ${OPENSHIFT_DATA_DIR}
export target_tmp_dir='xxx' # ${OPENSHIFT_TMP_DIR}

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

# apache

cd /tmp

wget http://ftp.riken.jp/net/apache//httpd/httpd-2.2.29.tar.bz2
tar jxf httpd-2.2.29.tar.bz2
cd httpd-2.2.29

./configure \
 --prefix=${target_data_dir}/apache \
 --mandir=${target_tmp_dir}/man \
 --docdir=${target_tmp_dir}/doc \
 --enable-mods-shared='all proxy'

time make -j$(grep -c -e processor /proc/cpuinfo)

cd ..
tar Jcf httpd.tar.xz httpd-2.2.29
rm -rf httpd-2.2.29

# libmemcached

cd /tmp

wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
tar zxf libmemcached-1.0.18.tar.gz
cd libmemcached-1.0.18

./configure \
 --prefix=${target_data_dir}/libmemcached \
 --mandir=${target_tmp_dir}/man \
 --docdir=${target_tmp_dir}/doc

time make -j2 -l3

cd ..
tar Jcf libmemcached.tar.xz libmemcached-1.0.18
rm -rf libmemcached-1.0.18

# delegate

cd /tmp

wget http://www.delegate.org/anonftp/DeleGate/delegate9.9.13.tar.gz
tar zxf delegate9.9.13.tar.gz

cd delegate9.9.13.tar.gz
time make -j$(grep -c -e processor /proc/cpuinfo)

cd ..
tar Jcf delegate.tar.xz delegate9.9.13
rm -rf delegate9.9.13

# Tcl

cd /tmp

wget http://prdownloads.sourceforge.net/tcl/tcl8.6.3-src.tar.gz
tar zxf tcl8.6.3-src.tar.gz

cd tcl8.6.3/unix

./configure \
 --prefix=${target_data_dir}/tcl \
 --mandir=${target_tmp_dir}/man \
 --disable-symbols

time make -j2 -l3

cd ../..
tar Jcf tcl.tar.xz tcl8.6.3
rm -rf tcl8.6.3
