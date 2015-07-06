#!/bin/bash

# 1508

export TZ=JST-9

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

set -x

cd /tmp

wget https://files4-20150524.rhcloud.com/files/5599764d4382ec427c0001d9_maked_ruby_2.1.6_rbenv.tar.xz
wget https://files4-20150524.rhcloud.com/files/5599764d4382ec427c0001d9_maked_php-5.6.10.tar.xz

ls -lang

rm -rf php-5.6.10

tar Jxf 5599764d4382ec427c0001d9_maked_php-5.6.10.tar.xz

tree php-5.6.10
