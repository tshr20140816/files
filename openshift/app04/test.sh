#!/bin/bash

echo "0940"

# set -x

cd /tmp

whereis java
wget http://closure-compiler.googlecode.com/files/compiler-latest.zip
unzip compiler-latest.zip

ls -lang

exit
