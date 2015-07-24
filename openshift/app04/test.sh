#!/bin/bash

# 1414

set -x

cd /tmp

ls -lang ${OPENSHIFT_LOG_DIR}

quota -s
