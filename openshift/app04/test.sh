#!/bin/bash

echo "1502"

# set -x

cd /tmp

rm -rf compiled

wget http://www.kokkonen.net/tjko/src/jpegoptim-1.4.3.tar.gz
tar xvfz jpegoptim-1.4.3.tar.gz
ls -lang
cd jpegoptim*
ls -lang
./configure --help

exit
