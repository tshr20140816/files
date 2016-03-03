#!/bin/bash

echo "0941"

# set -x

cd /tmp

whereis java
rm -f compiler-latest.zip
wget http://closure-compiler.googlecode.com/files/compiler-latest.zip
unzip compiler-latest.zip

ls -lang

exit
