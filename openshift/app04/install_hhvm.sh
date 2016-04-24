#!/bin/bash

# apache

cd /tmp
wget -nc -q http://ftp.kddilabs.jp/infosystems/apache//httpd/httpd-2.2.31.tar.bz2
tar xf httpd-2.2.31.tar.bz2
cd httpd-2.2.31
./configure --prefix=${OPENSHIFT_DATA_DIR}/apache --enable-mods-shared='all proxy'
time make -j4
make install

# fastcgi

cd /tmp
wget -nc -q https://www.pccc.com/downloads/apache/current/mod_fastcgi-current.tar.gz
tar xf mod_fastcgi-current.tar.gz
cd mod_fastcgi-2.4.6
make top_dir=${OPENSHIFT_DATA_DIR}/apache
make install top_dir=${OPENSHIFT_DATA_DIR}/apache
