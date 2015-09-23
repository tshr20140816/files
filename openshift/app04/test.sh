#!/bin/bash

set -x

quota -s

cd /tmp

# rm test.php
# wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app04/test.php
# cat test.php
# php test.php
# rm test.php

rm HPHP-2.1.0.zip
# wget https://github.com/facebook/hhvm/archive/HPHP-2.1.0.zip
# unzip HPHP-2.1.0.zip > /dev/null
rm HPHP-2.1.0.zip

ls -lang

export HPHP_HOME=${OPENSHIFT_DATA_DIR}

cd hhvm-HPHP-2.1.0
./configure --help
./configure

exit
