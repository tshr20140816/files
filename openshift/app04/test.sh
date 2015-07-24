#!/bin/bash

# 1414

set -x

cd /tmp

# wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.9.3/gcc-4.9.3.tar.bz2
tar jxf gcc-4.9.3.tar.bz2

cd gcc-4.9.3
rm -rf libjava

quota -s
