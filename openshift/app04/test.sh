#!/bin/bash

# 0859

set -x

cd ${OPENSHIFT_REPO_DIR}

rm -f test.php
wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app04/test.php

cat test.php
