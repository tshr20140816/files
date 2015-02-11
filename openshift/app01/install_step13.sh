#!/bin/bash

wget --spider `cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server`dummy?server=${OPENSHIFT_GEAR_DNS}\&part=`basename $0 .sh` >/dev/null 2>&1

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

# Cacti

set -x

export TZ=JST-9

pushd ${OPENSHIFT_DATA_DIR}/install_check_point > /dev/null
if -f [ `basename $0`.ok ]; then
    echo `date +%Y/%m/%d" "%H:%M:%S` Install Skip `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    exit
fi
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install Start `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# ***** Cacti *****

mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti
pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/cacti-${cacti_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` Cacti tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz cacti-${cacti_version}.tar.gz --strip-components=1
# cp ${OPENSHIFT_DATA_DIR}/download_files/security.patch ./
# patch -p1 -N < security.patch
popd > /dev/null

# create database
cactiuser_password=`uuidgen | base64 | head -c 25`
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cat << '__HEREDOC__' > create_database_cacti.txt
CREATE DATABASE cacti CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON cacti.* TO cactiuser@__OPENSHIFT_MYSQL_DB_HOST__ IDENTIFIED BY '__PASSWORD__';
FLUSH PRIVILEGES;
EXIT
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' create_database_cacti.txt
perl -pi -e "s/__PASSWORD__/${cactiuser_password}/g" create_database_cacti.txt

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" < create_database_cacti.txt

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" cacti < ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti/cacti.sql

echo `date +%Y/%m/%d" "%H:%M:%S` Cacti mysql cactiuser/${cactiuser_password} | tee -a ${OPENSHIFT_LOG_DIR}/install.log

cat << '__HEREDOC__' > ${OPENSHIFT_TMP_DIR}/config.php
<?php
$database_type = "mysql";
$database_default = "cacti";
$database_hostname = "__OPENSHIFT_MYSQL_DB_HOST__";
$database_username = "cactiuser";
$database_password = "__PASSWORD__";
$database_port = "3306";
$database_ssl = false;

$url_path = "/cacti/";
$cacti_session_name = "Cacti";
?>
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' ${OPENSHIFT_TMP_DIR}/config.php
perl -pi -e "s/__PASSWORD__/${cactiuser_password}/g" ${OPENSHIFT_TMP_DIR}/config.php
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti > /dev/null
mv include/config.php include/config.php.`date '+%Y%m%d'`
cp ${OPENSHIFT_TMP_DIR}/config.php include/
popd > /dev/null

# *** plugin ***

# * mURLin *

# TODO
# mURLin-${murlin_version}.tar.gz

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti > /dev/null
rm cacti-${cacti_version}.tar.gz
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/`basename $0`.ok

echo `date +%Y/%m/%d" "%H:%M:%S` Install Finish `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
