#!/bin/bash

echo "0947"

# set -x

cd /tmp

whereis java
rm -f compiler-latest.zip
rm -f README
#wget http://closure-compiler.googlecode.com/files/compiler-latest.zip
wget http://dl.google.com/closure-compiler/compiler-latest.zip
unzip compiler-latest.zip

ls -lang

exit
