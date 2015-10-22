#!/bin/bash

set -x

ls -al ${OPENSHIFT_REPO_DIR}

cd ${OPENSHIFT_REPO_DIR}

rm test.php*

wget https://github.com/tshr20140816/files/raw/master/openshift/app04/test.php
cp test.php test2.php

ls -al ${OPENSHIFT_REPO_DIR}

exit
