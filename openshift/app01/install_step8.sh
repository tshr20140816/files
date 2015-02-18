#!/bin/bash

source functions.sh
function010
$? && exit

# ***** wordpress *****

rm -rf ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress
mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress
pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/wordpress-${wordpress_version}.tar.gz ./
echo $(date +%Y/%m/%d" "%H:%M:%S) wordpress tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz wordpress-${wordpress_version}.tar.gz --strip-components=1
popd > /dev/null

# create database
wpuser_password=$(uuidgen | base64 | head -c 25)
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

// http://codex.wordpress.org/Administration_Over_SSL
define('FORCE_SSL_ADMIN', true);
if ($_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')
    $_SERVER['HTTPS']='on';

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');

__HEREDOC__
perl -pi -e "s/__LOG_DIR__/${OPENSHIFT_LOG_DIR}/g" wp-config.php

echo $(date +%Y/%m/%d" "%H:%M:%S) wordpress mysql wpuser/${wpuser_password} | tee -a ${OPENSHIFT_LOG_DIR}/install.log
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress > /dev/null
rm wordpress-${wordpress_version}.tar.gz
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo $(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename $0) | tee -a ${OPENSHIFT_LOG_DIR}/install.log
