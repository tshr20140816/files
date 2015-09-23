#!/bin/bash

set -x

echo "1715"

quota -s

cd /tmp

rm test.php
wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app04/test.php
cat test.php
php test.php
rm test.php

rm -rf hhvm-HPHP-2.1.0

exit
