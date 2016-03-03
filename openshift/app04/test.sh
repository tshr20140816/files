#!/bin/bash

echo "1549"

# set -x

cd /tmp

# wget http://www.kokkonen.net/tjko/src/jpegoptim-1.4.3.tar.gz
# tar xvfz jpegoptim-1.4.3.tar.gz
# ls -lang
# cd jpegoptim*
# ls -lang
# ./configure --help
# time ./configure --prefix=/tmp/jpegoptim
# time make
# time make install

# wget http://downloads.sourceforge.net/project/optipng/OptiPNG/optipng-0.7.5/optipng-0.7.5.tar.gz
# tar xvfz optipng-0.7.5.tar.gz
ls -lang
cd optipng*
./configure --help
time ./configure --prefix=/tmp/optipng
time make
time make install
exit
