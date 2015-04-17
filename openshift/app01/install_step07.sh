#!/bin/bash

source functions.sh
function010 stop
[ $? -eq 0 ] || exit

# ***** memcached *****

rm -rf ${OPENSHIFT_TMP_DIR}/memcached-${memcached_version}
rm -rf ${OPENSHIFT_DATA_DIR}/memcached

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/memcached-${memcached_version}.tar.gz ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached tar" >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz memcached-${memcached_version}.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/memcached-${memcached_version} > /dev/null

echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_memcached.log
CC="ccache gcc" CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s" CXXFLAGS="-O2 -march=native -pipe" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/memcached 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_memcached.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_memcached.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached.log
mv ${OPENSHIFT_LOG_DIR}/install_memcached.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm memcached-${memcached_version}.tar.gz
rm -rf memcached-${memcached_version}
popd > /dev/null

query_string="server=${OPENSHIFT_GEAR_DNS}&installed=memcached"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

# *** memcached-tool ***

mkdir -p ${OPENSHIFT_DATA_DIR}/local/bin
pushd ${OPENSHIFT_DATA_DIR}/local/bin > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/memcached-tool ./
chmod +x memcached-tool
popd > /dev/null

# ***** php *****

oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}' \
| tee -a ${OPENSHIFT_LOG_DIR}/install.log

rm -rf ${OPENSHIFT_TMP_DIR}/php-${php_version}
rm -rf ${OPENSHIFT_DATA_DIR}/php

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/php-${php_version}.tar.xz ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) php tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar Jxf php-${php_version}.tar.xz
popd > /dev/null

echo "$(date +%Y/%m/%d" "%H:%M:%S) php before" | tee -a ${OPENSHIFT_LOG_DIR}/ccache_stats.log
ccache -s | grep -e ^cache | tee -a ${OPENSHIFT_LOG_DIR}/ccache_stats.log

pushd ${OPENSHIFT_TMP_DIR}/php-${php_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) php configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_php.log
CC="ccache gcc" CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s" CXXFLAGS="-O2 -march=native -pipe" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/php \
--mandir=/tmp/man \
--docdir=/tmp/doc \
--with-apxs2=${OPENSHIFT_DATA_DIR}/apache/bin/apxs \
--with-mysql \
--with-pdo-mysql \
--without-sqlite3 \
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

echo "$(date +%Y/%m/%d" "%H:%M:%S) php make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_php.log
# j2 is limit (-l3 --load-average=3)
time make -j2 -l3 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_php.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) php make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_php.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_php.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) php make conf" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
cp php.ini-production ${OPENSHIFT_DATA_DIR}/php/lib/php.ini
cp php.ini-production ${OPENSHIFT_DATA_DIR}/php/lib/php.ini-production
cp php.ini-development ${OPENSHIFT_DATA_DIR}/php/lib/php.ini-development
mv ${OPENSHIFT_LOG_DIR}/install_php.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

echo "$(date +%Y/%m/%d" "%H:%M:%S) php after" | tee -a ${OPENSHIFT_LOG_DIR}/ccache_stats.log
ccache -s | grep -e ^cache | tee -a ${OPENSHIFT_LOG_DIR}/ccache_stats.log

oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}' \
| tee -a ${OPENSHIFT_LOG_DIR}/install.log

touch ${OPENSHIFT_LOG_DIR}/php_error.log

pushd ${OPENSHIFT_DATA_DIR}/php > /dev/null
perl -pi -e 's/^short_open_tag .+$/short_open_tag = On/g' lib/php.ini
perl -pi -e 's/(^;date.timezone =.*$)/$1\r\ndate.timezone = Asia\/Tokyo/g' lib/php.ini
perl -pi -e 's/(^;extension=php_xsl.*$)/$1\r\nextension=memcached.so/g' lib/php.ini
perl -pi -e 's/^(session.save_handler =).+$/$1 memcached/g' lib/php.ini
perl -pi -e 's/^;(session.save_path =).+$/$1 "$ENV{OPENSHIFT_DIY_IP}:31211"/g' lib/php.ini
perl -pi -e 's/^expose_php .+$/expose_php = Off/g' lib/php.ini
# TODO
perl -pi -e 's/(^;error_log =.*$)/error_log = __OPENSHIFT_LOG_DIR__\/php_error.log/g' lib/php.ini
sed -i -e "s|__OPENSHIFT_LOG_DIR__|${OPENSHIFT_LOG_DIR}|g" lib/php.ini

echo "$(date +%Y/%m/%d" "%H:%M:%S) php.ini diff" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
diff -u lib/php.ini-production lib/php.ini

popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm php-${php_version}.tar.xz
rm -rf php-${php_version}
popd > /dev/null

query_string="server=${OPENSHIFT_GEAR_DNS}&installed=php"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

# *** libmemcached ***

rm -rf ${OPENSHIFT_TMP_DIR}/libmemcached-${libmemcached_version}
rm -rf $OPENSHIFT_DATA_DIR/libmemcached

echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached before" | tee -a ${OPENSHIFT_LOG_DIR}/ccache_stats.log
ccache -s | grep -e ^cache | tee -a ${OPENSHIFT_LOG_DIR}/ccache_stats.log

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/libmemcached-${libmemcached_version}.tar.gz ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz libmemcached-${libmemcached_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/libmemcached-${libmemcached_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
CC="ccache gcc" CXX="ccache g++" \
CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s" CXXFLAGS="-O2 -march=native -pipe" \
enable_jobserver="no" \
 ./configure \
 --mandir=/tmp/man \
 --docdir=/tmp/doc \
 --prefix=${OPENSHIFT_DATA_DIR}/libmemcached 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_libmemcached.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
time make -j2 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_libmemcached.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
mv ${OPENSHIFT_LOG_DIR}/install_libmemcached.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached after" | tee -a ${OPENSHIFT_LOG_DIR}/ccache_stats.log
ccache -s | grep -e ^cache | tee -a ${OPENSHIFT_LOG_DIR}/ccache_stats.log

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm libmemcached-${libmemcached_version}.tar.gz
rm -rf libmemcached-${libmemcached_version}
popd > /dev/null

query_string="server=${OPENSHIFT_GEAR_DNS}&installed=libmemcached"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

# *** memcached php extension ***

rm -rf ${OPENSHIFT_TMP_DIR}/memcached-${memcached_php_ext_version}
rm -rf ${OPENSHIFT_DATA_DIR}/php_memcached

echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached php extension before" | tee -a ${OPENSHIFT_LOG_DIR}/ccache_stats.log
ccache -s | grep -e ^cache | tee -a ${OPENSHIFT_LOG_DIR}/ccache_stats.log

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/memcached-${memcached_php_ext_version}.tgz ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached_php_ext tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz memcached-${memcached_php_ext_version}.tgz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/memcached-${memcached_php_ext_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached_php_ext phpize" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
${OPENSHIFT_DATA_DIR}/php/bin/phpize
echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached_php_ext configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log
CC="ccache gcc" CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s" CXXFLAGS="-O2 -march=native -pipe" \
./configure \
--mandir=/tmp/man \
--prefix=${OPENSHIFT_DATA_DIR}/php_memcached \
--with-libmemcached-dir=$OPENSHIFT_DATA_DIR/libmemcached \
--disable-memcached-sasl \
--enable-memcached \
--with-php-config=${OPENSHIFT_DATA_DIR}/php/bin/php-config 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached_php_ext make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached_php_ext make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log
mv ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached php extension after" | tee -a ${OPENSHIFT_LOG_DIR}/ccache_stats.log
ccache -s | grep -e ^cache | tee -a ${OPENSHIFT_LOG_DIR}/ccache_stats.log

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm memcached-${memcached_php_ext_version}.tgz
rm -rf memcached-${memcached_php_ext_version}
popd > /dev/null

query_string="server=${OPENSHIFT_GEAR_DNS}&installed=memcached_php_ext"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
