#!/bin/bash

# 1507

export TZ=JST-9

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

set -x

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

cd /tmp
rm -f ccGfPr09.s
rm -f distcc_1af7ff60.ii
rm -f distcc_b4f80226.ii
rm -f distcc_server_stderr_b144bc50.txt
rm -rf man
cd $OPENSHIFT_DATA_DIR
rm -rf apache
rm -rf .gem
rm -rf .rbenv
tree .pki
tree .subversion

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}
