#!/bin/bash

set -x

while read LINE
do
  product=`echo $LINE | awk '{print $1}'`
  version=`echo $LINE | awk '{print $2}'`
  eval "$product"=$version
done < ${OPENSHIFT_TMP_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 7 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** wordpress *****

cd ${OPENSHIFT_DATA_DIR}/apache/htdocs
mkdir wordpress
cd wordpress
cp ${OPENSHIFT_TMP_DIR}/download_files/wordpress-${wordpress_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` wordpress tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz wordpress-${wordpress_version}.tar.gz --strip-components=1

# create database
wpuser_password=`uuidgen | base64 | head -c 25`
cd ${OPENSHIFT_TMP_DIR}
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

cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress
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
cp ${OPENSHIFT_TMP_DIR}/download_files/salt.txt ./
cat ${OPENSHIFT_TMP_DIR}/salt.txt >> wp-config.php
rm ${OPENSHIFT_TMP_DIR}/salt.txt
cat << '__HEREDOC__' >> wp-config.php

$table_prefix  = 'wp_';
define('WPLANG', 'ja');
define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');

__HEREDOC__

echo `date +%Y/%m/%d" "%H:%M:%S` wordpress mysql wpuser/${wpuser_password} >> ${OPENSHIFT_LOG_DIR}/install.log

cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress
rm wordpress-${wordpress_version}.tar.gz

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 7 Finish >> ${OPENSHIFT_LOG_DIR}/install.log

