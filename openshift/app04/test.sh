#!/bin/bash

echo "1028"

set -x

cd /tmp

whereis java
rm -f compiler-latest.zip
rm -f *.js
# rm -f README
# wget http://closure-compiler.googlecode.com/files/compiler-latest.zip
# wget http://dl.google.com/closure-compiler/compiler-latest.zip
# unzip compiler-latest.zip

wget https://foo-20140818.rhcloud.com/caldavzap/lib/jquery-ui-1.11.4.custom.js
wget https://foo-20140818.rhcloud.com/caldavzap/lib/spectrum.js

java -jar compiler.jar --version
java -jar compiler.jar --help

time java -jar compiler.jar --summary_detail_level 3 --js jquery-ui-1.11.4.custom.js --js_output_file jquery-ui-1.11.4.custom2.js
time java -jar compiler.jar --summary_detail_level 3 --js spectrum.js --js_output_file spectrum2.js

ls -lang

exit
