#!/bin/bash

echo "1333"

set -x

quota -s

cd /tmp

# wget http://soccer.phew.homeip.net/download/schedule/data/SJIS_all_hirosima.csv
rm test.php
wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app04/test.php
cat test.php
php test.php

rm test.php

exit

