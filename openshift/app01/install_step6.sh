et -x

while read LINE
do
  product=`echo $LINE | awk '{print $1}'`
  version=`echo $LINE | awk '{print $2}'`
  eval "$product"=$version
done < ${OPENSHIFT_TMP_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 6 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** memcached *****

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/memcached-${memcached_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` memcached tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz memcached-${memcached_version}.tar.gz
cd memcached-${memcached_version}

echo `date +%Y/%m/%d" "%H:%M:%S` memcached configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/memcached

echo `date +%Y/%m/%d" "%H:%M:%S` memcached make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j2
echo `date +%Y/%m/%d" "%H:%M:%S` memcached make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install

# ***** php *****

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/php-${php_version}.tar.gz ./
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

# ToDo
# for memcached
# lib/php.ini
# [Session]
# session.save_handler = memcached
# session.save_path = "__OPENSHIFT_DIY_IP__:31211" 
# perl -pi -e "s/__OPENSHIFT_DIY_IP__/${OPENSHIFT_DIY_IP}/g" lib/php.ini

cd ${OPENSHIFT_TMP_DIR}
rm php-${php_version}.tar.gz
rm -rf php-${php_version}

# *** libmemcached ***

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/libmemcached-${libmemcached_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz libmemcached-${libmemcached_version}.tar.gz
cd libmemcached-${libmemcached_version}
echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=$OPENSHIFT_DATA_DIR/libmemcached

echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached make >> ${OPENSHIFT_LOG_DIR}/install.log
time make
echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install

# *** memcached php extention ***

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/memcached-${memcached_php_ext_version}.tgz ./
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz memcached-${memcached_php_ext_version}.tgz
cd memcached-${memcached_php_ext_version}
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext phpize >> ${OPENSHIFT_LOG_DIR}/install.log
${OPENSHIFT_DATA_DIR}/php/bin/phpize
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/php_memcached \
--with-libmemcached-dir=$OPENSHIFT_DATA_DIR/libmemcached \
--disable-memcached-sasl \
--enable-memcached \
--with-php-config=${OPENSHIFT_DATA_DIR}/php/bin/php-config

echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext make >> ${OPENSHIFT_LOG_DIR}/install.log
time make
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 6 Finish >> ${OPENSHIFT_LOG_DIR}/install.log

