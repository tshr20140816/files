#!/bin/bash

echo "1609"

set -x

quota -s

cd /tmp

# rm test.php
# wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app04/test.php
# cat test.php
# php test.php
# rm test.php

rm HPHP-2.1.0.zip
wget https://github.com/facebook/hhvm/archive/HPHP-2.1.0.zip
unzip HPHP-2.1.0.zip
rm HPHP-2.1.0.zip
ls -lang

exit

