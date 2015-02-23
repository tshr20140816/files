#!/bin/bash

source functions.sh
function010
$? && exit

# ***** Baikal *****

rm -rf ${OPENSHIFT_DATA_DIR}/apache/htdocs/baikal-regular
rm -rf ${OPENSHIFT_DATA_DIR}/apache/htdocs/baikal

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/baikal-flat-${baikal_version}.zip ./
echo $(date +%Y/%m/%d" "%H:%M:%S) Baikal unzip | tee -a ${OPENSHIFT_LOG_DIR}/install.log
unzip baikal-flat-${baikal_version}.zip
mv baikal-flat baikal
touch baikal/Specific/ENABLE_INSTALL
rm baikal-flat-${baikal_version}.zip
popd > /dev/null

# create database
baikaluser_password=$(uuidgen | base64 | head -c 25)
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cat << '__HEREDOC__' > create_database_baikal.txt
CREATE DATABASE baikal CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON baikal.* TO baikaluser@__OPENSHIFT_MYSQL_DB_HOST__ IDENTIFIED BY '__PASSWORD__';
FLUSH PRIVILEGES;
EXIT
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' create_database_baikal.txt
perl -pi -e "s/__PASSWORD__/${baikaluser_password}/g" create_database_baikal.txt

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" < create_database_baikal.txt

echo $(date +%Y/%m/%d" "%H:%M:%S) Baikal mysql baikaluser/${baikaluser_password} | tee -a ${OPENSHIFT_LOG_DIR}/install.log
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo $(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename $0) | tee -a ${OPENSHIFT_LOG_DIR}/install.log
