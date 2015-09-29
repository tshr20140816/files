#!/bin/bash

set -x

echo "1507"

quota -s

cd /tmp

rm test.php
wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app04/test.php
cat test.php
php test.php
rm test.php

ls -lang

ls -lang ${OPENSHIFT_REPO_DIR}

ls -lang ${OPENSHIFT_DATA_DIR}

exit
