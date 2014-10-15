#!/bin/bash

set -x

while read LINE
do
  product=`echo $LINE | awk '{print $1}'`
  version=`echo $LINE | awk '{print $2}'`
  eval "$product"=$version
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 12 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** rrdtool *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/rrdtool-${rrdtool_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` rrdtool tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar rrdtool-${rrdtool_version}.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}rrdtool-${rrdtool_version} > /dev/null
echo `date +%Y/%m/%d" "%H:%M:%S` rrdtool configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/rrdtool 2>&1 | tee ${OPENSHIFT_LOG_DIR}/rrdtool.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` rrdtool make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j2
echo `date +%Y/%m/%d" "%H:%M:%S` rrdtool make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm rrdtool-${rrdtool_version}.tar.gz
rm -rf rrdtool-${rrdtool_version}
popd > /dev/null

# ***** Cacti *****

mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti
pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/cacti-${cacti_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` Cacti tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz cacti-${cacti_version}.tar.gz --strip-components=1
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

echo `date +%Y/%m/%d" "%H:%M:%S` Cacti mysql cactiuser/${cactiuser_password} >> ${OPENSHIFT_LOG_DIR}/install.log

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

mv include/config.php include/config.php.org
cp ${OPENSHIFT_TMP_DIR}/config.php include/

popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti > /dev/null
rm cacti-${cacti_version}.tar.gz
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 12 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
