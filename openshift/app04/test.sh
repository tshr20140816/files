#!/bin/bash

set -x

cd ${OPENSHIFT_REPO_DIR}

rm -f test.php
wget https://github.com/tshr20140816/files/blob/master/openshift/app04/test.php

cat test.php
