#!/bin/bash

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

# apache

cd /tmp
wget -nc -q http://ftp.kddilabs.jp/infosystems/apache//httpd/httpd-2.2.31.tar.bz2
tar jxf httpd-2.2.31.tar.bz2
cd httpd-2.2.31
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/apache --enable-mods-shared='all proxy'
time make -j4
make install

# fastcgi

cd /tmp
wget -nc -q https://www.pccc.com/downloads/apache/current/mod_fastcgi-current.tar.gz
tar zxf mod_fastcgi-current.tar.gz
cd mod_fastcgi-2.4.6
time make top_dir=${OPENSHIFT_DATA_DIR}/apache
make install top_dir=${OPENSHIFT_DATA_DIR}/apache

# boost

cd /tmp
wget -nc -q http://heanet.dl.sourceforge.net/project/boost/boost/1.54.0/boost_1_54_0.tar.bz2
tar jxf boost_1_54_0.tar.bz2
cd boost_1_54_0
export HOME=${OPENSHIFT_DATA_DIR}
cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/user-config.jam
using gcc : : gcc : <cflags>"-O2 -march=native -fomit-frame-pointer -s -pipe" <cxxflags>"-O2 -march=native -fomit-frame-pointer -s -pipe" ;
__HEREDOC__
./bootstrap.sh
./b2 --help
time ./b2 install -j1 --prefix=$OPENSHIFT_DATA_DIR/boost \
 --libdir=$OPENSHIFT_DATA_DIR/usr/lib \
 --link=shared \
 --runtime-link=shared \
 --without-atomic \
 --without-chrono \
 --without-context \
 --without-coroutine \
 --without-date_time \
 --without-exception \
 --without-graph \
 --without-graph_parallel \
 --without-iostreams \
 --without-locale \
 --without-log \
 --without-math \
 --without-mpi \
 --without-python \
 --without-random \
 --without-serialization \
 --without-signals \
 --without-test \
 --without-timer \
 --without-wave
 
 tree -a $OPENSHIFT_DATA_DIR/usr/lib
 
