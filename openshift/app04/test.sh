#!/bin/bash

set -x

# 1536

ls -al ${OPENSHIFT_REPO_DIR}

cd ${OPENSHIFT_REPO_DIR}

rm test.php*

wget https://github.com/tshr20140816/files/raw/master/openshift/app04/test.php
cat test.php
php test.php

ls -al ${OPENSHIFT_REPO_DIR}

exit
