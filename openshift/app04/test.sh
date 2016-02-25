#!/bin/bash

set -x

cd /tmp

rm -f v4.0.10.zip
rm -rf apcu-4.0.10

wget http://www.graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.38.0.tar.gz
tar xfz graphviz-2.38.0.tar.gz
ls -lang
cd graphviz*
./configure --help
./configure
make

exit
