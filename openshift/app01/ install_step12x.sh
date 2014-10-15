#!/usr/bash

cd /tmp/
wget http://prdownloads.sourceforge.net/tcl/tcl8.6.2-src.tar.gz
tar xfz tcl8.6.2-src.tar.gz
cd tcl8.6.2
cd unix
./configure --prefix=${OPENSHIFT_DATA_DIR}/tcl
make
make install
