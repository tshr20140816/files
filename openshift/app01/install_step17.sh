#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
find ${OPENSHIFT_DATA_DIR} -name *.sh -type f -print0 | xargs -0i bash -n {} 2>&1 >> ${OPENSHIFT_LOG_DIR}/shell_syntax_error.log
find ${OPENSHIFT_CRON_DIR} -name *.sh -type f -print0 | xargs -0i bash -n {} 2>&1 >> ${OPENSHIFT_LOG_DIR}/shell_syntax_error.log
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
