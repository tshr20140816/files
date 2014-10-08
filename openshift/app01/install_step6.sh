#!/bin/bash

set -x

while read LINE
do
  product=`echo $LINE | awk '{print $1}'`
  version=`echo $LINE | awk '{print $2}'`
  eval "$product"=$version
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 6 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** memcached *****

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_DATA_DIR}/download_files/memcached-${memcached_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` memcached tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz memcached-${memcached_version}.tar.gz
cd memcached-${memcached_version}

echo `date +%Y/%m/%d" "%H:%M:%S` memcached configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/memcached 2>&1 | tee ${OPENSHIFT_LOG_DIR}/memcached.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` memcached make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j2
echo `date +%Y/%m/%d" "%H:%M:%S` memcached make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm memcached-${memcached_version}.tar.gz
rm -rf memcached-${memcached_version}
popd > /dev/null

# *** memcached-tool ***

mkdir -p ${OPENSHIFT_DATA_DIR}/local/bin
pushd ${OPENSHIFT_DATA_DIR}/local/bin > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/memcached-tool ./
chmod +x memcached-tool
popd > /dev/null

# ***** php *****

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_DATA_DIR}/download_files/php-${php_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` php tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz php-${php_version}.tar.gz
cd php-${php_version}
echo `date +%Y/%m/%d" "%H:%M:%S` php configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/php \
--with-apxs2=${OPENSHIFT_DATA_DIR}/apache/bin/apxs \
--with-mysql \
--with-pdo-mysql \
--with-curl \
--with-libdir=lib64 \
--with-bz2 \
--with-iconv \
--with-openssl \
--with-zlib \
--enable-exif \
--enable-ftp \
--enable-xml \
--enable-mbstring \
--enable-mbregex \
--enable-sockets \
--with-gettext=${OPENSHIFT_DATA_DIR}/php 2>&1 | tee ${OPENSHIFT_LOG_DIR}/php.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` php make >> ${OPENSHIFT_LOG_DIR}/install.log
time make
echo `date +%Y/%m/%d" "%H:%M:%S` php make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
echo `date +%Y/%m/%d" "%H:%M:%S` php make conf >> ${OPENSHIFT_LOG_DIR}/install.log
cp php.ini-production ${OPENSHIFT_DATA_DIR}/php/lib/php.ini
cp php.ini-production ${OPENSHIFT_DATA_DIR}/php/lib/php.ini-production
cp php.ini-development ${OPENSHIFT_DATA_DIR}/php/lib/php.ini-development
cd ${OPENSHIFT_DATA_DIR}/php
perl -pi -e 's/^short_open_tag .+$/short_open_tag = On/g' lib/php.ini
perl -pi -e 's/(^;date.timezone =.*$)/$1\r\ndate.timezone = Asia\/Tokyo/g' lib/php.ini
perl -pi -e 's/(^;extension=php_xsl.*$)/$1\r\nextension=memcached.so/g' lib/php.ini
perl -pi -e 's/^(session.save_handler =).+$/$1 memcached/g' lib/php.ini
perl -pi -e 's/^;(session.save_path =).+$/$1 "$ENV{OPENSHIFT_DIY_IP}:31211"/g' lib/php.ini

echo `date +%Y/%m/%d" "%H:%M:%S` php.ini patch check >> ${OPENSHIFT_LOG_DIR}/install.log
cat lib/php.ini | grep short_open_tag >> ${OPENSHIFT_LOG_DIR}/install.log
cat lib/php.ini | grep date.timezone >> ${OPENSHIFT_LOG_DIR}/install.log
cat lib/php.ini | grep memcached.so >> ${OPENSHIFT_LOG_DIR}/install.log
cat lib/php.ini | grep session.save_handler >> ${OPENSHIFT_LOG_DIR}/install.log
cat lib/php.ini | grep session.save_path >> ${OPENSHIFT_LOG_DIR}/install.log

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm php-${php_version}.tar.gz
rm -rf php-${php_version}
popd > /dev/null

# *** libmemcached ***

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/libmemcached-${libmemcached_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz libmemcached-${libmemcached_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/libmemcached-${libmemcached_version} > /dev/null
echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=$OPENSHIFT_DATA_DIR/libmemcached 2>&1 | tee ${OPENSHIFT_LOG_DIR}/libmemcached.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j3
echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm libmemcached-${libmemcached_version}.tar.gz
rm -rf libmemcached-${libmemcached_version}
popd > /dev/null

# *** memcached php extention ***

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/memcached-${memcached_php_ext_version}.tgz ./
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz memcached-${memcached_php_ext_version}.tgz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/memcached-${memcached_php_ext_version} > /dev/null
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext phpize >> ${OPENSHIFT_LOG_DIR}/install.log
${OPENSHIFT_DATA_DIR}/php/bin/phpize
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/php_memcached \
--with-libmemcached-dir=$OPENSHIFT_DATA_DIR/libmemcached \
--disable-memcached-sasl \
--enable-memcached \
--with-php-config=${OPENSHIFT_DATA_DIR}/php/bin/php-config 2>&1 | tee ${OPENSHIFT_LOG_DIR}/memcached_php_extention.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext make >> ${OPENSHIFT_LOG_DIR}/install.log
time make
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm memcached-${memcached_php_ext_version}.tgz
rm -rf memcached-${memcached_php_ext_version}
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 6 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
