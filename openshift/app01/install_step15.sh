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
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cat << '__HEREDOC__' > create_database_baikal.txt
DROP DATABASE IF EXISTS baikal;
CREATE DATABASE baikal CHARACTER SET utf8 COLLATE utf8_general_ci;
EXIT
__HEREDOC__

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" < create_database_baikal.txt

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
sed -i -e 's|"PROJECT_DB_MYSQL_USERNAME" => ""|"PROJECT_DB_MYSQL_USERNAME" => "__OPENSHIFT_MYSQL_DB_USERNAME__"|g' Database.php
sed -i -e 's|"PROJECT_DB_MYSQL_PASSWORD" => ""|"PROJECT_DB_MYSQL_PASSWORD" => "__OPENSHIFT_MYSQL_DB_PASSWORD__"|g' Database.php
sed -i -e "s|__PROJECT_DB_MYSQL_HOST__|${OPENSHIFT_MYSQL_DB_HOST}:${OPENSHIFT_MYSQL_DB_PORT}|g" Database.php
sed -i -e "s|__OPENSHIFT_MYSQL_DB_USERNAME__|${OPENSHIFT_MYSQL_DB_USERNAME}|g" Database.php
sed -i -e "s|__OPENSHIFT_MYSQL_DB_PASSWORD__|${OPENSHIFT_MYSQL_DB_PASSWORD}|g" Database.php

# *** System.php ***

sed -i -e 's|"PROJECT_DB_MYSQL" => FALSE|"PROJECT_DB_MYSQL" => TRUE|g' System.php
sed -i -e 's|"PROJECT_DB_MYSQL_HOST" => ""|"PROJECT_DB_MYSQL_HOST" => "__PROJECT_DB_MYSQL_HOST__"|g' System.php
sed -i -e 's|"PROJECT_DB_MYSQL_DBNAME" => ""|"PROJECT_DB_MYSQL_DBNAME" => "baikal"|g' System.php
sed -i -e 's|"PROJECT_DB_MYSQL_USERNAME" => ""|"PROJECT_DB_MYSQL_USERNAME" => "__OPENSHIFT_MYSQL_DB_USERNAME__"|g' System.php
sed -i -e 's|"PROJECT_DB_MYSQL_PASSWORD" => ""|"PROJECT_DB_MYSQL_PASSWORD" => "__OPENSHIFT_MYSQL_DB_PASSWORD__"|g' System.php
sed -i -e 's|define("PROJECT_DB_MYSQL", FALSE);|define("PROJECT_DB_MYSQL", TRUE);|g' System.php
sed -i -e 's|define("PROJECT_DB_MYSQL_HOST", "");|define("PROJECT_DB_MYSQL_HOST", "__PROJECT_DB_MYSQL_HOST__");|g' System.php
sed -i -e 's|define("PROJECT_DB_MYSQL_DBNAME", "");|define("PROJECT_DB_MYSQL_DBNAME", "baikal");|g' System.php
sed -i -e 's|define("PROJECT_DB_MYSQL_USERNAME", "");|define("PROJECT_DB_MYSQL_USERNAME", "__OPENSHIFT_MYSQL_DB_USERNAME__");|g' System.php
sed -i -e 's|define("PROJECT_DB_MYSQL_PASSWORD", "");|define("PROJECT_DB_MYSQL_PASSWORD", "__OPENSHIFT_MYSQL_DB_PASSWORD__");|g' System.php
sed -i -e "s|__PROJECT_DB_MYSQL_HOST__|${OPENSHIFT_MYSQL_DB_HOST}:${OPENSHIFT_MYSQL_DB_PORT}|g" System.php
sed -i -e "s|__OPENSHIFT_MYSQL_DB_USERNAME__|${OPENSHIFT_MYSQL_DB_USERNAME}|g" System.php
sed -i -e "s|__OPENSHIFT_MYSQL_DB_PASSWORD__|${OPENSHIFT_MYSQL_DB_PASSWORD}|g" System.php

popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/baikal/Core/Resources/Db/MySQL > /dev/null

cp db.sql db.sql.$(date '+%Y%m%d')
sed -i -e '1s|^|SET GLOBAL innodb_file_per_table=1;\nSET GLOBAL innodb_file_format=Barracuda;\n\n|' db.sql
perl -pi -e 's/(ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci)/${1} ROW_FORMAT=compressed KEY_BLOCK_SIZE=4/g' db.sql

popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/system > /dev/null
cat << '__HEREDOC__' > baikal.php
<?php
touch(getenv('OPENSHIFT_DATA_DIR') . '/apache/htdocs/baikal/Specific/ENABLE_INSTALL');
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
sed -i -e "s|__GLOBAL_NETWORK_CHECK_SETTINGS_HREF__|location.protocol+'//'+location.hostname+'/baikal/cal.php/principals/'|g" config.js

perl -pi -e "s/^var globalInterfaceLanguage='en_US';/var globalInterfaceLanguage='ja_JP';/g" config.js

perl -pi -e "s/^var globalDatepickerFormat='dd.mm.yy';/var globalDatepickerFormat='yyyy\/mm\/dd';/g" config.js

perl -pi -e "s/^var globalDatepickerFirstDayOfWeek=1;/var globalDatepickerFirstDayOfWeek=0;/g" config.js

perl -pi -e "s/^var globalCalendarStartOfBusiness=8;/var globalCalendarStartOfBusiness=0;/g" config.js
perl -pi -e "s/^var globalCalendarEndOfBusiness=17;/var globalCalendarEndOfBusiness=24;/g" config.js

perl -pi -e "s/^var globalTimeZone='Europe\/Berlin';/var globalTimeZone='Asia\/Tokyo';/g" config.js

perl -pi -e "s/^\/\/var globalUseJqueryAuth=.+$/var globalUseJqueryAuth=true;/g" config.js

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

# ***** phpicalendar *****

rmdir -rf ${OPENSHIFT_DATA_DIR}/apache/htdocs/cal
mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/cal

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/cal > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/phpicalendar-${phpicalendar_version}.tar.bz2 ./
tar jxf phpicalendar-${phpicalendar_version}.tar.bz2 --strip-components=1

patch functions/ical_parser.php ${OPENSHIFT_DATA_DIR}/github/openshift/app01/ical_parser.php.patch

cp config.inc.php config.inc.php.$(date '+%Y%m%d')
cat << '__HEREDOC__' > config.inc.php
<?php

$configs = array(
'default_path' => 'https://__OPENSHIFT_APP_DNS__/cal/',
'timezone' => '+09:00',
'language' => 'Japanese',
'default_view' => 'month',
'week_start_day' => 'Sunday',
'phpicalendar_publishing' => 1,
}

$blacklisted_cals = array(
''
);

$list_webcals = array(
);
__HEREDOC__
sed -i -e "s|__OPENSHIFT_APP_DNS__|${OPENSHIFT_APP_DNS}|g" config.inc.php

rm phpicalendar-${phpicalendar_version}.tar.bz2
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
