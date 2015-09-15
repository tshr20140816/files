#!/bin/bash

set -x

quota -s

cd /tmp

wget http://www.delegate.org/anonftp/DeleGate/delegate9.9.13.tar.gz

tar zxf delegate9.9.13.tar.gz

cd delegate9.9.13

time make -j4 ADMIN=user@rhcloud.local

mkdir ${OPENSHIFT_DATA_DIR}/delegate/
cp src/delegated ${OPENSHIFT_DATA_DIR}/delegate/
