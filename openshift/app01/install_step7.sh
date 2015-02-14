#!/bin/bash

wget --spider `cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server`dummy?server=${OPENSHIFT_GEAR_DNS}\&part=`basename $0 .sh` >/dev/null 2>&1

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

set -x

export TZ=JST-9

pushd ${OPENSHIFT_DATA_DIR}/install_check_point > /dev/null
if [ -f `basename $0`.ok ]; then
    echo `date +%Y/%m/%d" "%H:%M:%S` Install Skip `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    exit
fi
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install Start `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

/usr/bin/gear stop

echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# ***** memcached *****

rm -rf ${OPENSHIFT_TMP_DIR}/memcached-${memcached_version}
rm -rf ${OPENSHIFT_DATA_DIR}/memcached

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/memcached-${memcached_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` memcached tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz memcached-${memcached_version}.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/memcached-${memcached_version} > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` memcached configure | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `date +%Y/%m/%d" "%H:%M:%S` '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_memcached.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/memcached 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached.log

echo `date +%Y/%m/%d" "%H:%M:%S` memcached make | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_memcached.log
time make -j4 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached.log

echo `date +%Y/%m/%d" "%H:%M:%S` memcached make install | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_memcached.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached.log
popd > /dev/null

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

echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

rm -rf ${OPENSHIFT_TMP_DIR}/php-${php_version}
rm -rf ${OPENSHIFT_DATA_DIR}/php

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/php-${php_version}.tar.xz ./
echo `date +%Y/%m/%d" "%H:%M:%S` php tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar Jxf php-${php_version}.tar.xz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/php-${php_version} > /dev/null
echo `date +%Y/%m/%d" "%H:%M:%S` php configure | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `date +%Y/%m/%d" "%H:%M:%S` '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_php.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/php \
--mandir=/tmp/man \
--docdir=/tmp/doc \
--with-apxs2=${OPENSHIFT_DATA_DIR}/apache/bin/apxs \
--with-mysql \
--with-pdo-mysql \
--without-pdo-sqlite \
--with-curl \
--with-libdir=lib64 \
--with-bz2 \
--with-iconv \
--with-openssl \
--with-zlib \
--with-gd \
--enable-exif \
--enable-ftp \
--enable-xml \
--enable-mbstring \
--enable-mbregex \
--enable-sockets \
--disable-ipv6 \
--with-gettext=${OPENSHIFT_DATA_DIR}/php 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_php.log

echo `date +%Y/%m/%d" "%H:%M:%S` php make | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_php.log
time make 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_php.log
echo `date +%Y/%m/%d" "%H:%M:%S` php make install | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_php.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_php.log
echo `date +%Y/%m/%d" "%H:%M:%S` php make conf | tee -a ${OPENSHIFT_LOG_DIR}/install.log
cp php.ini-production ${OPENSHIFT_DATA_DIR}/php/lib/php.ini
cp php.ini-production ${OPENSHIFT_DATA_DIR}/php/lib/php.ini-production
cp php.ini-development ${OPENSHIFT_DATA_DIR}/php/lib/php.ini-development
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/php > /dev/null
perl -pi -e 's/^short_open_tag .+$/short_open_tag = On/g' lib/php.ini
perl -pi -e 's/(^;date.timezone =.*$)/$1\r\ndate.timezone = Asia\/Tokyo/g' lib/php.ini
perl -pi -e 's/(^;extension=php_xsl.*$)/$1\r\nextension=memcached.so/g' lib/php.ini
perl -pi -e 's/^(session.save_handler =).+$/$1 memcached/g' lib/php.ini
perl -pi -e 's/^;(session.save_path =).+$/$1 "$ENV{OPENSHIFT_DIY_IP}:31211"/g' lib/php.ini

echo `date +%Y/%m/%d" "%H:%M:%S` php.ini patch check | tee -a ${OPENSHIFT_LOG_DIR}/install.log
cat lib/php.ini | grep short_open_tag | tee -a ${OPENSHIFT_LOG_DIR}/install.log
cat lib/php.ini | grep date.timezone | tee -a ${OPENSHIFT_LOG_DIR}/install.log
cat lib/php.ini | grep memcached.so | tee -a ${OPENSHIFT_LOG_DIR}/install.log
cat lib/php.ini | grep session.save_handler | tee -a ${OPENSHIFT_LOG_DIR}/install.log
cat lib/php.ini | grep session.save_path | tee -a ${OPENSHIFT_LOG_DIR}/install.log
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm php-${php_version}.tar.xz
rm -rf php-${php_version}
popd > /dev/null

# *** libmemcached ***

echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

rm -rf ${OPENSHIFT_TMP_DIR}/libmemcached-${libmemcached_version}
rm -rf $OPENSHIFT_DATA_DIR/libmemcached

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/libmemcached-${libmemcached_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz libmemcached-${libmemcached_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/libmemcached-${libmemcached_version} > /dev/null
echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached configure | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `date +%Y/%m/%d" "%H:%M:%S` '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--mandir=/tmp/man \
--prefix=$OPENSHIFT_DATA_DIR/libmemcached 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_libmemcached.log

echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached make | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
time make -j4 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_libmemcached.log

echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached make install | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm libmemcached-${libmemcached_version}.tar.gz
rm -rf libmemcached-${libmemcached_version}
popd > /dev/null

# *** memcached php extention ***

echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

rm -rf ${OPENSHIFT_TMP_DIR}/memcached-${memcached_php_ext_version}
rm -rf ${OPENSHIFT_DATA_DIR}/php_memcached

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/memcached-${memcached_php_ext_version}.tgz ./
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext tar | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz memcached-${memcached_php_ext_version}.tgz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/memcached-${memcached_php_ext_version} > /dev/null
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext phpize | tee -a ${OPENSHIFT_LOG_DIR}/install.log
${OPENSHIFT_DATA_DIR}/php/bin/phpize
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext configure | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `date +%Y/%m/%d" "%H:%M:%S` '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_memcached_php_extention.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/php_memcached \
--with-libmemcached-dir=$OPENSHIFT_DATA_DIR/libmemcached \
--disable-memcached-sasl \
--enable-memcached \
--with-php-config=${OPENSHIFT_DATA_DIR}/php/bin/php-config 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_libmemcached.log

echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext make | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_memcached_php_extention.log
time make -j4 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_libmemcached.log

echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext make install | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'`date +%Y/%m/%d" "%H:%M:%S` '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_memcached_php_extention.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm memcached-${memcached_php_ext_version}.tgz
rm -rf memcached-${memcached_php_ext_version}
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/`basename $0`.ok

/usr/bin/gear start

echo `date +%Y/%m/%d" "%H:%M:%S` Install Finish `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
