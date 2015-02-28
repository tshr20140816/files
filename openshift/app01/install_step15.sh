#!/bin/bash

source functions.sh
function010 restart
[ $? -eq 0 ] || exit

# ***** Baikal *****

rm -rf ${OPENSHIFT_DATA_DIR}/apache/htdocs/baikal-regular
rm -rf ${OPENSHIFT_DATA_DIR}/apache/htdocs/baikal
rm -f ${OPENSHIFT_DATA_DIR}/apache/htdocs/baikal-flat-${baikal_version}.zip

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/baikal-flat-${baikal_version}.zip ./
echo $(date +%Y/%m/%d" "%H:%M:%S) Baikal unzip | tee -a ${OPENSHIFT_LOG_DIR}/install.log
unzip baikal-flat-${baikal_version}.zip
mv baikal-flat baikal
touch baikal/Specific/ENABLE_INSTALL
popd > /dev/null

# create database
baikaluser_password=$(uuidgen | base64 | head -c 25)
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cat << '__HEREDOC__' > create_database_baikal.txt
DROP DATABASE IF EXISTS baikal;
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

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/baikal/Core/Frameworks/Baikal/Model/Config > /dev/null

# *** Starndard.php ***

sed -i -e 's|Europe/Paris|Asia/Tokyo|g' Standard.php
sed -i -e 's|"BAIKAL_CARD_ENABLED" => TRUE|"BAIKAL_CARD_ENABLED" => FALSE|g' Standard.php
sed -i -e 's|define("BAIKAL_CARD_ENABLED", TRUE);|define("BAIKAL_CARD_ENABLED", FALSE);|g' Standard.php

# *** Database.php ***

sed -i -e 's|"PROJECT_DB_MYSQL" => FALSE|"PROJECT_DB_MYSQL" => TRUE|g' Database.php
sed -i -e 's|"PROJECT_DB_MYSQL_HOST" => ""|"PROJECT_DB_MYSQL_HOST" => "__PROJECT_DB_MYSQL_HOST__"|g' Database.php
sed -i -e 's|"PROJECT_DB_MYSQL_DBNAME" => ""|"PROJECT_DB_MYSQL_DBNAME" => "baikal"|g' Database.php
sed -i -e 's|"PROJECT_DB_MYSQL_USERNAME" => ""|"PROJECT_DB_MYSQL_USERNAME" => "baikaluser"|g' Database.php
sed -i -e 's|"PROJECT_DB_MYSQL_PASSWORD" => ""|"PROJECT_DB_MYSQL_PASSWORD" => "__PROJECT_DB_MYSQL_PASSWORD__"|g' Database.php
sed -i -e "s|__PROJECT_DB_MYSQL_HOST__|${OPENSHIFT_MYSQL_DB_HOST}:${OPENSHIFT_MYSQL_DB_PORT}|g" Database.php
sed -i -e "s|__PROJECT_DB_MYSQL_PASSWORD__|${baikaluser_password}|g" Database.php

# *** System.php ***

sed -i -e 's|"PROJECT_DB_MYSQL" => FALSE|"PROJECT_DB_MYSQL" => TRUE|g' System.php
sed -i -e 's|"PROJECT_DB_MYSQL_HOST" => ""|"PROJECT_DB_MYSQL_HOST" => "__PROJECT_DB_MYSQL_HOST__"|g' System.php
sed -i -e 's|"PROJECT_DB_MYSQL_DBNAME" => ""|"PROJECT_DB_MYSQL_DBNAME" => "baikal"|g' System.php
sed -i -e 's|"PROJECT_DB_MYSQL_USERNAME" => ""|"PROJECT_DB_MYSQL_USERNAME" => "baikaluser"|g' System.php
sed -i -e 's|"PROJECT_DB_MYSQL_PASSWORD" => ""|"PROJECT_DB_MYSQL_PASSWORD" => "__PROJECT_DB_MYSQL_PASSWORD__"|g' System.php
sed -i -e 's|define("PROJECT_DB_MYSQL", FALSE);|define("PROJECT_DB_MYSQL", TRUE);|g' System.php
sed -i -e 's|define("PROJECT_DB_MYSQL_HOST", "");|define("PROJECT_DB_MYSQL_HOST", "__PROJECT_DB_MYSQL_HOST__");|g' System.php
sed -i -e 's|define("PROJECT_DB_MYSQL_DBNAME", "");|define("PROJECT_DB_MYSQL_DBNAME", "baikal");|g' System.php
sed -i -e 's|define("PROJECT_DB_MYSQL_USERNAME", "");|define("PROJECT_DB_MYSQL_USERNAME", "baikaluser");|g' System.php
sed -i -e 's|define("PROJECT_DB_MYSQL_PASSWORD", "");|define("PROJECT_DB_MYSQL_PASSWORD", "__PROJECT_DB_MYSQL_PASSWORD__");|g' System.php
sed -i -e "s|__PROJECT_DB_MYSQL_HOST__|${OPENSHIFT_MYSQL_DB_HOST}:${OPENSHIFT_MYSQL_DB_PORT}|g" System.php
sed -i -e "s|__PROJECT_DB_MYSQL_PASSWORD__|${baikaluser_password}|g" System.php

popd > /dev/null

mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/system
pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/system > /dev/null

# * htaccess *

echo AuthType Digest > .htaccess
echo AuthUserFile ${OPENSHIFT_DATA_DIR}/apache/.htpasswd >> .htaccess
cat << '__HEREDOC__' >> .htaccess
AuthName realm

require valid-user

<Files ~ "^.(htpasswd|htaccess)$">
    deny from all
</Files>
__HEREDOC__

touch index.html

cat << '__HEREDOC__' >> index.php
<?php
system('touch ' . getenv('OPENSHIFT_DATA_DIR') . '/apache/htdocs/baikal/Specific/ENABLE_INSTALL');
?>
__HEREDOC__

popd > /dev/null

rm ${OPENSHIFT_DATA_DIR}/apache/htdocs/baikal-flat-${baikal_version}.zip

# ***** CalDavZAP *****

rm -rf ${OPENSHIFT_DATA_DIR}/apache/htdocs/caldavzap
rm -f ${OPENSHIFT_DATA_DIR}/apache/htdocs/CalDavZAP_${caldavzap_version}.zip

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/CalDavZAP_${caldavzap_version}.zip ./
echo $(date +%Y/%m/%d" "%H:%M:%S) CalDavZAP unzip | tee -a ${OPENSHIFT_LOG_DIR}/install.log
unzip CalDavZAP_${caldavzap_version}.zip
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/caldavzap/ > /dev/null

# *** config.js ***

dt=$(date '+%Y%m%d')
cp config.js config.js.${dt}

perl -pi -e 's/^var globalNetworkCheckSettings={href: .+, hrefLabel:(.+$)/var globalNetworkCheckSettings={href: __GLOBAL_NETWORK_CHECK_SETTINGS_HREF__, hrefLabel:${1}/g' config.js
sed -i -e "s|__GLOBAL_NETWORK_CHECK_SETTINGS_HREF__|location.protocol+'//'+location.hostname+'/baikal/cal.php/'|g" config.js

perl -pi -e "s/^var globalInterfaceLanguage='en_US';/var globalInterfaceLanguage='ja_JP';/g" config.js

perl -pi -e "s/^var globalDatepickerFormat='dd.mm.yy';/var globalDatepickerFormat='yyyy\/mm\/dd';/g" config.js

perl -pi -e "s/^var globalDatepickerFirstDayOfWeek=1;/var globalDatepickerFirstDayOfWeek=0;/g" config.js

perl -pi -e "s/^var globalCalendarStartOfBusiness=8;/var globalCalendarStartOfBusiness=0;/g" config.js
perl -pi -e "s/^var globalCalendarEndOfBusiness=17;/var globalCalendarEndOfBusiness=24;/g" config.js

perl -pi -e "s/^var globalTimeZone='Europe\/Berlin';/var globalTimeZone='Asia\/Tokyo';/g" config.js

diff -u config.js.${dt} config.js
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/ > /dev/null

cat << '__HEREDOC__' >> conf/custom.conf
<Directory __OPENSHIFT_DATA_DIR__/apache/htdocs/caldavzap/>
    AllowOverride FileInfo Limit
    Order allow,deny
    Allow from all
</Directory>
__HEREDOC__
popd > /dev/null

rm ${OPENSHIFT_DATA_DIR}/apache/htdocs/CalDavZAP_${caldavzap_version}.zip

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo $(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename $0) | tee -a ${OPENSHIFT_LOG_DIR}/install.log
