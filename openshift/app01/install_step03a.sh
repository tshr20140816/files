#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** YUI Compressor *****

cp ${OPENSHIFT_DATA_DIR}/download_files/yuicompressor-${yuicompressor_version}.jar ${OPENSHIFT_DATA_DIR}/yuicompressor.jar

java -jar ${OPENSHIFT_DATA_DIR}/yuicompressor.jar --version

# ***** Closure Compiler *****

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/compiler-latest.zip ./compiler-latest.zip
unzip compiler-latest.zip
rm -f compiler-latest.zip

java -jar ${OPENSHIFT_DATA_DIR}/compiler.jar --version

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename "${0}").ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
