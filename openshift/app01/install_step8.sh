#!/bin/bash

wget --spider `cat ${OPENSHIFT_DATA_DIR}/web_beacon_server`dummy?server=${OPENSHIFT_GEAR_DNS}\&part=`basename $0 .sh` >/dev/null 2>&1

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

set -x

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 8 Start | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# ***** wordpress *****

mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress
pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/wordpress-${wordpress_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` wordpress tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz wordpress-${wordpress_version}.tar.gz --strip-components=1
popd > /dev/null

# create database
wpuser_password=`uuidgen | base64 | head -c 25`
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cat << '__HEREDOC__' > create_database_wordpress.txt
CREATE DATABASE wordpress CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON wordpress.* TO wpuser@__OPENSHIFT_MYSQL_DB_HOST__ IDENTIFIED BY '__PASSWORD__';
FLUSH PRIVILEGES;
EXIT
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' create_database_wordpress.txt
perl -pi -e "s/__PASSWORD__/${wpuser_password}/g" create_database_wordpress.txt

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" < create_database_wordpress.txt
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress > /dev/null
cat << '__HEREDOC__' > wp-config.php
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wpuser');
define('DB_PASSWORD', '__PASSWORD__');
define('DB_HOST', getenv('OPENSHIFT_MYSQL_DB_HOST') . ':' . getenv('OPENSHIFT_MYSQL_DB_PORT'));
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', 'utf8_general_ci');
__HEREDOC__
perl -pi -e "s/__PASSWORD__/${wpuser_password}/g" wp-config.php
cp ${OPENSHIFT_DATA_DIR}/download_files/salt.txt ./
cat ./salt.txt >> wp-config.php
rm ./salt.txt
cat << '__HEREDOC__' >> wp-config.php

$table_prefix  = 'wp_';
define('WPLANG', 'ja');

define('WP_DEBUG', false);
ini_set('display_errors', 0);
ini_set("log_errors", 1);
ini_set("error_log", "__LOG_DIR__wordpress_error.log");

define('FORCE_SSL_ADMIN', true);
if ($_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')
    $_SERVER['HTTPS']='on';

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');

__HEREDOC__
perl -pi -e "s/__LOG_DIR__/${OPENSHIFT_LOG_DIR}/g" wp-config.php

# force ssl patch
mkdir -p wp-content/mu-plugins
cp ${OPENSHIFT_DATA_DIR}/download_files/is_ssl.php wp-content/mu-plugins/
# perl -pi -e 's/(^function is_ssl\(\) \{)$/$1\n\treturn is_maybe_ssl\(\);/g' wp-includes/functions.php

echo `date +%Y/%m/%d" "%H:%M:%S` wordpress mysql wpuser/${wpuser_password} | tee -a ${OPENSHIFT_LOG_DIR}/install.log
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress > /dev/null
rm wordpress-${wordpress_version}.tar.gz
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 8 Finish | tee -a ${OPENSHIFT_LOG_DIR}/install.log
