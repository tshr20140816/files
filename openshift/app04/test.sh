#!/bin/bash

# 1426

# ls -lang ${OPENSHIFT_LOG_DIR}

set -x

curl --version

exit

cd ${OPENSHIFT_REPO_DIR}

ls -lang

nohup php test.php >${OPENSHIFT_LOG_DIR}test.php.log 2>&1 &

ls -lang

exit

cd ${OPENSHIFT_REPO_DIR}

rm -f debian.*.xml

rm -f test.php
wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app04/test.php

php -l test.php
cat test.php

cd /tmp

wget https://tenv-20150207.rhcloud.com/test.php

cat test.php
rm test.php

cd ${OPENSHIFT_REPO_DIR}

ls -lang
