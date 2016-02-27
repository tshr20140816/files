#!/bin/bash

source functions.sh
function010 restart
[ $? -eq 0 ] || exit

export HOME=${OPENSHIFT_DATA_DIR}
rm -f ${OPENSHIFT_DATA_DIR}/.distcc/lock/backoff*
for line in $(cat ${OPENSHIFT_DATA_DIR}/params/user_fqdn.txt)
do
    user_fqdn=$(echo "${line}")
    # ssh -O check -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    ssh -t -t -O check -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
done

# apache インストールの前で実施(時間短縮のため)
# # ***** memcached *****
# 
# rm -rf ${OPENSHIFT_TMP_DIR}/memcached-${memcached_version}
# rm -rf ${OPENSHIFT_DATA_DIR}/memcached
# 
# pushd ${OPENSHIFT_TMP_DIR} > /dev/null
# cp -f ${OPENSHIFT_DATA_DIR}/download_files/memcached-${memcached_version}.tar.gz ./
# echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached tar" >> ${OPENSHIFT_LOG_DIR}/install.log
# tar zxf memcached-${memcached_version}.tar.gz
# popd > /dev/null
# 
# pushd ${OPENSHIFT_TMP_DIR}/memcached-${memcached_version} > /dev/null
# 
# echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_memcached.log
# ./configure \
# --mandir=${OPENSHIFT_TMP_DIR}/man \
# --prefix=${OPENSHIFT_DATA_DIR}/memcached 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached.log
# 
# echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_memcached.log
# # time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached.log
# time make -j12 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached.log
# 
# echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_memcached.log
# make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached.log
# mv ${OPENSHIFT_LOG_DIR}/install_memcached.log ${OPENSHIFT_LOG_DIR}/install/
# popd > /dev/null
# 
# pushd ${OPENSHIFT_TMP_DIR} > /dev/null
# rm memcached-${memcached_version}.tar.gz
# rm -rf memcached-${memcached_version}
# popd > /dev/null
# 
# query_string="server=${OPENSHIFT_APP_DNS}&installed=memcached"
# wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1
# 
# # *** memcached-tool ***
# 
# mkdir -p ${OPENSHIFT_DATA_DIR}/local/bin
# pushd ${OPENSHIFT_DATA_DIR}/local/bin > /dev/null
# cp -f ${OPENSHIFT_DATA_DIR}/download_files/memcached-tool ./
# chmod +x memcached-tool
# popd > /dev/null

# ***** php *****

oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}' \
| tee -a ${OPENSHIFT_LOG_DIR}/install.log

rm -f ${OPENSHIFT_DATA_DIR}/.distcc/lock/backoff*
rm -rf ${OPENSHIFT_TMP_DIR}/php-${php_version}
rm -rf ${OPENSHIFT_DATA_DIR}/php

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

unlink apache
ln -s ${OPENSHIFT_DATA_DIR}/apache apache

if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    file_name=${OPENSHIFT_APP_UUID}_maked_php-${php_version}.tar.xz
    url=$(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    while :
    do
        if [ $(wget -nv --spider --timeout 60 -t 1 ${url} 2>&1 | grep -c '200 OK') -eq 1 ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) php maked wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            break
        else
            echo "$(date +%Y/%m/%d" "%H:%M:%S) php maked waiting" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            sleep 10s
        fi
    done
    wget $(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    echo "$(date +%Y/%m/%d" "%H:%M:%S) php maked tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar Jxf ${file_name}
    rm ${file_name}
else
    cp -f ${OPENSHIFT_DATA_DIR}/download_files/ccache_php.tar.xz ./
    if [ -f ccache_php.tar.xz ]; then
        rm -rf ccache
        tar Jxf ccache_php.tar.xz
        ccache -s
        export CC="ccache gcc"
        export CXX="ccache g++"
        export CCACHE_PREFIX=distcc
    fi

    cp -f ${OPENSHIFT_DATA_DIR}/download_files/php-${php_version}.tar.xz ./
    echo "$(date +%Y/%m/%d" "%H:%M:%S) php tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar Jxf php-${php_version}.tar.xz
    rm php-${php_version}.tar.xz
fi
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/php-${php_version} > /dev/null

# *** configure make install ***

if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    export CC="ccache gcc"
    export CXX="ccache g++"
else
    echo "$(date +%Y/%m/%d" "%H:%M:%S) php configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_php.log
    ./configure \
     --prefix=${OPENSHIFT_DATA_DIR}/php \
     --mandir=${OPENSHIFT_TMP_DIR}/man \
     --docdir=${OPENSHIFT_TMP_DIR}/doc \
     --infodir=${OPENSHIFT_TMP_DIR}/info \
     --with-apxs2=${OPENSHIFT_TMP_DIR}/apache/bin/apxs \
     --with-mysql \
     --with-pdo-mysql \
     --without-sqlite3 \
     --without-pdo-sqlite \
     --without-cdb \
     --without-pear \
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
     --enable-opcache \
     --enable-sockets \
     --enable-pcntl \
     --disable-ipv6 \
     --disable-debug \
     --with-gettext=${OPENSHIFT_DATA_DIR}/php \
     --with-zend-vm=GOTO 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_php.log

    echo "$(date +%Y/%m/%d" "%H:%M:%S) php make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_php.log
    # j2 is limit (-l3 --load-average=3)
    # time make -j2 -l3 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_php.log
    time make -j12 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_php.log
    ccache --show-stats
fi

echo "$(date +%Y/%m/%d" "%H:%M:%S) php make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_php.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_php.log

export HOME=${env_home_backup}
echo "$(date +%Y/%m/%d" "%H:%M:%S) php make conf" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
cp php.ini-production ${OPENSHIFT_DATA_DIR}/php/lib/php.ini
cp php.ini-production ${OPENSHIFT_DATA_DIR}/php/lib/php.ini-production
cp php.ini-development ${OPENSHIFT_DATA_DIR}/php/lib/php.ini-development
mv ${OPENSHIFT_LOG_DIR}/install_php.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}' \
 | tee -a ${OPENSHIFT_LOG_DIR}/install.log

touch ${OPENSHIFT_LOG_DIR}/php_error.log

pushd ${OPENSHIFT_DATA_DIR}/php > /dev/null
perl -pi -e 's/^short_open_tag .+$/short_open_tag = On/g' lib/php.ini
perl -pi -e 's/(^;date.timezone =.*$)/$1\ndate.timezone = Asia\/Tokyo/g' lib/php.ini
perl -pi -e 's/(^;extension=php_xsl.*$)/$1\nextension=apcu.so/g' lib/php.ini
perl -pi -e 's/(^;extension=php_xsl.*$)/$1\nextension=memcached.so/g' lib/php.ini
perl -pi -e 's/^(session.save_handler =).+$/$1 memcached/g' lib/php.ini
perl -pi -e 's/^;(session.save_path =).+$/$1 "$ENV{OPENSHIFT_DIY_IP}:31211"/g' lib/php.ini
perl -pi -e 's/^expose_php .+$/expose_php = Off/g' lib/php.ini
perl -pi -e 's/(^;always_populate_raw_post_data =.*$)/$1\nalways_populate_raw_post_data = -1/g' lib/php.ini
perl -pi -e 's/(^;error_log =.*$)/error_log = __OPENSHIFT_LOG_DIR__\/php_error.log/g' lib/php.ini
sed -i -e "s|__OPENSHIFT_LOG_DIR__|${OPENSHIFT_LOG_DIR}|g" lib/php.ini
cat << '__HEREDOC__' >> lib/php.ini

apc.enabled=1
apc.shm_size=8M
apc.ttl=7200
apc.enable_cli=1
__HEREDOC__

echo "$(date +%Y/%m/%d" "%H:%M:%S) php.ini diff" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
diff -u lib/php.ini-production lib/php.ini

popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm php-${php_version}.tar.xz
rm -rf php-${php_version}
popd > /dev/null

php_installed_version=$(${OPENSHIFT_DATA_DIR}/php/bin/php -v | head -n 1 | perl -MURI::Escape -lne 'print uri_escape($_)')
query_string="server=${OPENSHIFT_APP_DNS}&installed=php&version=${php_installed_version}"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

# *** libmemcached ***

rm -rf ${OPENSHIFT_TMP_DIR}/libmemcached-${libmemcached_version}
rm -rf $OPENSHIFT_DATA_DIR/libmemcached

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    file_name=${OPENSHIFT_APP_UUID}_maked_libmemcached-${libmemcached_version}.tar.xz
    if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_2) != 'none' ]; then
        url=$(cat ${OPENSHIFT_DATA_DIR}/params/build_server_2)/${file_name}
    else
        url=$(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    fi
    while :
    do
        if [ $(wget -nv --spider --timeout 60 -t 1 ${url} 2>&1 | grep -c '200 OK') -eq 1 ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached maked wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            break
        else
            echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached maked waiting" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            sleep 10s
        fi
    done
    wget $(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached maked tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar Jxf ${file_name}
    rm -f ${file_name}
else
    cp -f ${OPENSHIFT_DATA_DIR}/download_files/libmemcached-${libmemcached_version}.tar.gz ./
    echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar zxf libmemcached-${libmemcached_version}.tar.gz
fi
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/libmemcached-${libmemcached_version} > /dev/null
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    export CC="ccache gcc"
    export CXX="ccache g++"
else
    echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
    enable_jobserver="no" \
     ./configure \
     --mandir=${OPENSHIFT_TMP_DIR}/man \
     --docdir=${OPENSHIFT_TMP_DIR}/doc \
     --prefix=${OPENSHIFT_DATA_DIR}/libmemcached 2>&1 \
     | tee -a ${OPENSHIFT_LOG_DIR}/install_libmemcached.log

    echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
    time make -j2 -l3 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
    # function030 libmemcached "-j2 -l3"
fi

echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_libmemcached.log
mv ${OPENSHIFT_LOG_DIR}/install_libmemcached.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null
unset CC
unset CXX

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm libmemcached-${libmemcached_version}.tar.gz
rm -rf libmemcached-${libmemcached_version}
popd > /dev/null

query_string="server=${OPENSHIFT_APP_DNS}&installed=libmemcached"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

# *** memcached php extension ***

rm -rf ${OPENSHIFT_TMP_DIR}/memcached-${memcached_php_ext_version}
rm -rf ${OPENSHIFT_DATA_DIR}/php_memcached

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/memcached-${memcached_php_ext_version}.tgz ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached_php_ext tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar zxf memcached-${memcached_php_ext_version}.tgz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/memcached-${memcached_php_ext_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached_php_ext phpize" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
${OPENSHIFT_DATA_DIR}/php/bin/phpize
echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached_php_ext configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log
./configure \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --prefix=${OPENSHIFT_DATA_DIR}/php_memcached \
 --with-libmemcached-dir=$OPENSHIFT_DATA_DIR/libmemcached \
 --disable-memcached-sasl \
 --enable-memcached \
 --with-php-config=${OPENSHIFT_DATA_DIR}/php/bin/php-config 2>&1 \
 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached_php_ext make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached_php_ext make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log
mv ${OPENSHIFT_LOG_DIR}/install_memcached_php_extension.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm memcached-${memcached_php_ext_version}.tgz
rm -rf memcached-${memcached_php_ext_version}
popd > /dev/null

query_string="server=${OPENSHIFT_APP_DNS}&installed=memcached_php_ext"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

# *** apcu ***

rm -f ${OPENSHIFT_TMP_DIR}/apcu-${apcu_version}.zip
rm -rf ${OPENSHIFT_TMP_DIR}/apcu-${apcu_version}

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/apcu-${apcu_version}.zip ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) apcu unzip" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
unzip apcu-${apcu_version}.zip
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/apcu-${apcu_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) apcu phpize" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
${OPENSHIFT_DATA_DIR}/php/bin/phpize
echo "$(date +%Y/%m/%d" "%H:%M:%S) apcu configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_apcu.log
./configure \
 --with-php-config=${OPENSHIFT_DATA_DIR}/php/bin/php-config
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --prefix=${OPENSHIFT_DATA_DIR}/apcu 2>&1 \
 | tee -a ${OPENSHIFT_LOG_DIR}/install_apcu.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) apcu make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_apcu.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_apcu.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) apcu make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_apcu.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_apcu.log
mv ${OPENSHIFT_LOG_DIR}/install_apcu.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm apcu-${apcu_version}.zip
rm -rf apcu-${apcu_version}
popd > /dev/null

query_string="server=${OPENSHIFT_APP_DNS}&installed=apcu"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

# php.ini ★
# extension=apcu.so
# apc.enabled=1
# apc.shm_size=32M
# apc.ttl=7200
# apc.enable_cli=1

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
