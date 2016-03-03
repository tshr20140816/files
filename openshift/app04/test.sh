#!/bin/bash

echo "1121"

# set -x

cd /tmp

mkdir compiled

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
# java -jar compiler.jar --help

time java -jar compiler.jar --summary_detail_level 3 --js jquery-ui-1.11.4.custom.js --js_output_file compiled/jquery-ui-1.11.4.custom.js 2> result.txt
if [ "$(cat ./result.txt)" = "0 error(s), 0 warning(s)" ]; then
    echo "MATCH"
fi
time java -jar compiler.jar --summary_detail_level 3 --js spectrum.js --js_output_file compiled/spectrum.js 2> result.txt
if [ "$(cat ./result.txt)" = "0 error(s), 0 warning(s)" ]; then
    echo "MATCH"
fi

find ./ -name "*.js" -type f -print0 | xargs -n1 -0i echo {}

ls -lang

exit
