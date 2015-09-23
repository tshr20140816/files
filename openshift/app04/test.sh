#!/bin/bash

echo "1345"

set -x

quota -s

cd /tmp

rm ${OPENSHIFT_REPO_DIR}test.ics
rm ${OPENSHIFT_REPO_DIR}test.xml

exit

