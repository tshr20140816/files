#!/bin/bash

set -x

echo "1743"

quota -s

cd /tmp

ls -lang

ls -lang ${OPENSHIFT_REPO_DIR}

ls -lang ${OPENSHIFT_DATA_DIR}

exit
