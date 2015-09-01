#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** squid *****

rm -f ${OPENSHIFT_TMP_DIR}/squid-${squid_version}.tar.xz
rm -f ${OPENSHIFT_TMP_DIR}/${OPENSHIFT_APP_UUID}_maked_squid-${squid_version}.tar.xz
rm -rf ${OPENSHIFT_TMP_DIR}/squid-${squid_version}
rm -rf ${OPENSHIFT_DATA_DIR}/squid


