#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** Cacti *****

rm -rf ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti
mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti
pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/cacti-${cacti_version}.tar.gz ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) Cacti tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
time tar zxf cacti-${cacti_version}.tar.gz --strip-components=1
# cp ${OPENSHIFT_DATA_DIR}/download_files/security.patch ./
# patch -p1 -N < security.patch
popd > /dev/null

# create database
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cat << '__HEREDOC__' > create_database_cacti.txt
DROP DATABASE IF EXISTS cacti;
CREATE DATABASE cacti CHARACTER SET utf8 COLLATE utf8_general_ci;
__HEREDOC__

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" < create_database_cacti.txt

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" cacti < ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti/cacti.sql

cat << '__HEREDOC__' > ${OPENSHIFT_TMP_DIR}/config.php
<?php
$database_type = "mysql";
$database_default = "cacti";
$database_hostname = "__OPENSHIFT_MYSQL_DB_HOST__";
$database_username = "__OPENSHIFT_MYSQL_DB_USERNAME__";
$database_password = "__OPENSHIFT_MYSQL_DB_PASSWORD__";
$database_port = "__OPENSHIFT_MYSQL_DB_PORT__";
$database_ssl = false;

$url_path = "/cacti/";
$cacti_session_name = "Cacti";
?>
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' ${OPENSHIFT_TMP_DIR}/config.php
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_USERNAME__/$ENV{OPENSHIFT_MYSQL_DB_USERNAME}/g' ${OPENSHIFT_TMP_DIR}/config.php
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_PASSWORD__/$ENV{OPENSHIFT_MYSQL_DB_PASSWORD}/g' ${OPENSHIFT_TMP_DIR}/config.php
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_PORT__/$ENV{OPENSHIFT_MYSQL_DB_PORT}/g' ${OPENSHIFT_TMP_DIR}/config.php
php -l ${OPENSHIFT_TMP_DIR}/config.php
popd > /dev/null

# *** change default password ***

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
user_default_password=$(cat ${OPENSHIFT_DATA_DIR}/params/user_default_password)

cat << __HEREDOC__ > update_default_password.sql
UPDATE user_auth
   SET password=MD5('${user_default_password}')
 WHERE username = 'admin';
EXIT
__HEREDOC__

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
 --password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
 -h "${OPENSHIFT_MYSQL_DB_HOST}" \
 -P "${OPENSHIFT_MYSQL_DB_PORT}" cacti < update_default_password.sql
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti > /dev/null
mv include/config.php include/config.php.$(date '+%Y%m%d')
cp ${OPENSHIFT_TMP_DIR}/config.php include/
popd > /dev/null

# *** plugin ***

# * mURLin *

# TODO
# mURLin-${murlin_version}.tar.gz

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti > /dev/null
rm cacti-${cacti_version}.tar.gz
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
