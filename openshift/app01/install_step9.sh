#!/bin/bash

wget --spider `cat ${OPENSHIFT_DATA_DIR}/web_beacon_server`dummy?server=${OPENSHIFT_GEAR_DNS}&part=`basename $0 .sh` >/dev/null 2>&1

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

set -x

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 9 Start | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# ***** Tiny Tiny RSS *****

mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss
pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/${ttrss_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` Tiny Tiny RSS tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz ${ttrss_version}.tar.gz --strip-components=1
popd > /dev/null

# create database
ttrssuser_password=`uuidgen | base64 | head -c 25`
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cat << '__HEREDOC__' > create_database_ttrss.txt
CREATE DATABASE ttrss CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON ttrss.* TO ttrssuser@__OPENSHIFT_MYSQL_DB_HOST__ IDENTIFIED BY '__PASSWORD__';
FLUSH PRIVILEGES;
EXIT
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' create_database_ttrss.txt
perl -pi -e "s/__PASSWORD__/${ttrssuser_password}/g" create_database_ttrss.txt

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" < create_database_ttrss.txt

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" ttrss < ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss/schema/ttrss_schema_mysql.sql

echo `date +%Y/%m/%d" "%H:%M:%S` Tiny Tiny RSS mysql ttrssuser/${ttrssuser_password} | tee -a ${OPENSHIFT_LOG_DIR}/install.log
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss > /dev/null

cp config.php-dist config.php
perl -pi -e "s/define\(\'DB_TYPE\', \"pgsql\"/define('DB_TYPE', 'mysql'/g" config.php
perl -pi -e "s/define\(\'DB_HOST\', \"localhost\"/define('DB_HOST', getenv('OPENSHIFT_MYSQL_DB_HOST')/g" config.php
perl -pi -e "s/define\(\'DB_USER\', \"fox\"/define('DB_USER', 'ttrssuser'/g" config.php
perl -pi -e "s/define\(\'DB_NAME\', \"fox\"/define('DB_NAME', 'ttrss'/g" config.php
perl -pi -e "s/define\(\'DB_PASS\', \"XXXXXX\"/define('DB_PASS', '${ttrssuser_password}'/g" config.php
perl -pi -e "s/define\(\'DB_PORT\', \'\'/define('DB_PORT', getenv('OPENSHIFT_MYSQL_DB_PORT')/g" config.php
perl -pi -e "s/define\(\'MYSQL_CHARSET\', \'UTF8\'\);/define('_ENABLE_PDO', true);\r\n        define('MYSQL_CHARSET', 'UTF8');/g" config.php
perl -pi -e "s/define\(\'SELF_URL_PATH\', \'http:\/\/example.org\/tt-rss\/\'/define('SELF_URL_PATH', 'http:\/\/${OPENSHIFT_APP_DNS}\/ttrss\/'/g" config.php
# TODO
# perl -pi -e "s/define\(\'PHP_EXECUTABLE\', \'\/usr\/bin\/php\'/define('PHP_EXECUTABLE', getenv('OPENSHIFT_DATA_DIR')\/php\/bin\/php/g" config.php
perl -pi -e "s/define\(\'ENABLE_GZIP_OUTPUT\', false/define('ENABLE_GZIP_OUTPUT', true/g" config.php

# TODO
# Invalid command 'zlib.output_compression'
# echo zlib.output_compression off > .htaccess
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss > /dev/null
rm ${ttrss_version}.tar.gz
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 9 Finish | tee -a ${OPENSHIFT_LOG_DIR}/install.log
