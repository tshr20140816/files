#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** Tiny Tiny RSS *****

rm -rf ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss

mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss
pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/${ttrss_version}.tar.gz ./
echo $(date +%Y/%m/%d" "%H:%M:%S) Tiny Tiny RSS tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz ${ttrss_version}.tar.gz --strip-components=1
popd > /dev/null

# *** create database ***
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cat << '__HEREDOC__' > create_database_ttrss.txt
DROP DATABASE IF EXISTS ttrss;
CREATE DATABASE ttrss CHARACTER SET utf8 COLLATE utf8_general_ci;
EXIT
__HEREDOC__

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" < create_database_ttrss.txt

# *** create tables ***

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" ttrss < ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss/schema/ttrss_schema_mysql.sql

# *** format compact -> compress

cat << '__HEREDOC__' > ${OPENSHIFT_TMP_DIR}/sql.txt
SET GLOBAL innodb_file_per_table=1;
SET GLOBAL innodb_file_format=Barracuda;
ALTER TABLE ttrss_user_entries ENGINE=InnoDB ROW_FORMAT=compressed KEY_BLOCK_SIZE=8;
ALTER TABLE ttrss_entries ENGINE=InnoDB ROW_FORMAT=compressed KEY_BLOCK_SIZE=8;
ALTER TABLE ttrss_tags ENGINE=InnoDB ROW_FORMAT=compressed KEY_BLOCK_SIZE=8;
__HEREDOC__

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" ttrss < ${OPENSHIFT_TMP_DIR}/sql.txt

rm ${OPENSHIFT_TMP_DIR}/sql.txt

popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss > /dev/null

cp config.php-dist config.php
perl -pi -e "s/define\(\'DB_TYPE\', \"pgsql\"/define('DB_TYPE', 'mysql'/g" config.php
perl -pi -e "s/define\(\'DB_HOST\', \"localhost\"/define('DB_HOST', getenv('OPENSHIFT_MYSQL_DB_HOST')/g" config.php
perl -pi -e "s/define\(\'DB_USER\', \"fox\"/define('DB_USER', 'getenv('OPENSHIFT_MYSQL_DB_USERNAME')'/g" config.php
perl -pi -e "s/define\(\'DB_NAME\', \"fox\"/define('DB_NAME', 'ttrss'/g" config.php
perl -pi -e "s/define\(\'DB_PASS\', \"XXXXXX\"/define('DB_PASS', 'getenv('OPENSHIFT_MYSQL_DB_PASSWORD')'/g" config.php
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

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo $(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename $0) | tee -a ${OPENSHIFT_LOG_DIR}/install.log
