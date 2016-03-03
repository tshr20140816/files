#!/bin/bash

echo "0958"

# set -x

cd /tmp

whereis java
rm -f compiler-latest.zip
# rm -f README
# wget http://closure-compiler.googlecode.com/files/compiler-latest.zip
# wget http://dl.google.com/closure-compiler/compiler-latest.zip
# unzip compiler-latest.zip

wget https://foo-20140818.rhcloud.com/caldavzap/lib/jquery-ui-1.11.4.custom.js

java -jar compiler.jar --js jquery-ui-1.11.4.custom.js --js_output_file jquery-ui-1.11.4.custom2.js

ls -lang

cat jquery-ui-1.11.4.custom2.js

exit
