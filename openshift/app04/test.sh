#!/bin/bash

# 1327

ls -lang ${OPENSHIFT_LOG_DIR}

set -x

cd ${OPENSHIFT_REPO_DIR}

rm -f test.php
wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app04/test.php

php -l test.php
cat test.php
