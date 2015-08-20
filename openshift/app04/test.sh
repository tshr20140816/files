#!/bin/bash

set -x

quota -s

cd /tmp

export PATH="${OPENSHIFT_TMP_DIR}/gcc/bin:$PATH"
export LD_LIBRARY_PATH="${OPENSHIFT_TMP_DIR}/gcc/lib64:$LD_LIBRARY_PATH"
export CC=gcc-493
export CXX=gcc-493

gcc-493 --version
