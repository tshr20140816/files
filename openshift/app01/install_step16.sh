#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** Tiny Tiny RSS *****

rm -rf ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/ttrss_archive.zip ./
time unzip ttrss_archive.zip
mv tt-rss.git ttrss
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

function020 ttrss

popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss > /dev/null

cp config.php-dist config.php
perl -pi -e "s/define\(\'DB_TYPE\', \"pgsql\"/define('DB_TYPE', 'mysql'/g" config.php
perl -pi -e "s/define\(\'DB_HOST\', \"localhost\"/define('DB_HOST', getenv('OPENSHIFT_MYSQL_DB_HOST')/g" config.php
perl -pi -e "s/define\(\'DB_USER\', \"fox\"/define('DB_USER', getenv('OPENSHIFT_MYSQL_DB_USERNAME')/g" config.php
perl -pi -e "s/define\(\'DB_NAME\', \"fox\"/define('DB_NAME', 'ttrss'/g" config.php
perl -pi -e "s/define\(\'DB_PASS\', \"XXXXXX\"/define('DB_PASS', getenv('OPENSHIFT_MYSQL_DB_PASSWORD')/g" config.php
perl -pi -e "s/define\(\'DB_PORT\', \'\'/define('DB_PORT', getenv('OPENSHIFT_MYSQL_DB_PORT')/g" config.php
perl -pi -e "s/define\(\'MYSQL_CHARSET\', \'UTF8\'\);/define('_ENABLE_PDO', true);\r\n        define('MYSQL_CHARSET', 'UTF8');/g" config.php
perl -pi -e "s/define\(\'SELF_URL_PATH\', \'http:\/\/example.org\/tt-rss\/\'/define('SELF_URL_PATH', 'http:\/\/${OPENSHIFT_APP_DNS}\/ttrss\/'/g" config.php
# TODO
# perl -pi -e "s/define\(\'PHP_EXECUTABLE\', \'\/usr\/bin\/php\'/define('PHP_EXECUTABLE', getenv('OPENSHIFT_DATA_DIR')\/php\/bin\/php/g" config.php
perl -pi -e "s/define\(\'ENABLE_GZIP_OUTPUT\', false/define('ENABLE_GZIP_OUTPUT', true/g" config.php
echo >> config.php
echo -e "\tdefine('_CURL_HTTP_PROXY', getenv('OPENSHIFT_DIY_IP') . ':33128');" >> config.php

php -l config.php
# TODO
# Invalid command 'zlib.output_compression'
# echo zlib.output_compression off > .htaccess
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs > /dev/null
rm ttrss_archive.zip
popd > /dev/null

# *** change default password ***

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
user_default_password=$(cat ${OPENSHIFT_DATA_DIR}/params/user_default_password)
user_default_password_sha1=$(echo -n ${user_default_password}  | openssl sha1 | awk '{print $2;}')

cat << __HEREDOC__ > update_default_password.sql
UPDATE ttrss_users
   SET pwd_hash='SHA1:${user_default_password_sha1}'
 WHERE login = 'admin';
EXIT
__HEREDOC__

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" ttrss < update_default_password.sql
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
