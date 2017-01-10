#!/bin/bash

echo "1112"

set -x

quota -s
oo-cgroup-read memory.failcnt
echo "$(oo-cgroup-read memory.usage_in_bytes)" | awk '{printf "%\047d\n", $0}'

# oo-cgroup-read all
# oo-cgroup-read report

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

/usr/bin/gear start --trace

cd /tmp
ls -lang
cd $OPENSHIFT_DATA_DIR
ls -lang

ls -lang $OPENSHIFT_REPO_DIR

quota -s

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd ${OPENSHIFT_TMP_DIR}

if [ 1 -eq 0 ]; then

# ***** apache *****

# *** pcre ***

pcre_version=8.39

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -q ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${pcre_version}.tar.bz2
tar xf pcre-${pcre_version}.tar.bz2
pushd pcre-${pcre_version} > /dev/null
./configure --help > ${OPENSHIFT_LOG_DIR}/configure_pcre
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr --enable-static=no
time make -j4
make install
popd > /dev/null
rm -rf pcre-${pcre_version}
rm -f pcre-${pcre_version}.tar.bz2
popd > /dev/null

# *** httpd ***

apache_version=2.4.25
apr_version=1.5.2
aprutil_version=1.5.4

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -q http://ftp.yz.yamagata-u.ac.jp/pub/network/apache//httpd/httpd-${apache_version}.tar.bz2
tar xf httpd-${apache_version}.tar.bz2

wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-${apr_version}.tar.bz2
tar xf apr-${apr_version}.tar.bz2
mv -f ./apr-${apr_version} ./httpd-${apache_version}/srclib/apr

wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-util-${aprutil_version}.tar.bz2
tar xf apr-util-${aprutil_version}.tar.bz2
mv -f ./apr-util-${aprutil_version} ./httpd-${apache_version}/srclib/apr-util

pushd httpd-${apache_version} > /dev/null
./configure --help > ${OPENSHIFT_LOG_DIR}/configure_apache
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr \
 --with-pcre=${OPENSHIFT_DATA_DIR}/usr
time make -j4
make install
popd > /dev/null
rm -rf httpd-${apache_version}
rm -f *.tar.bz2
popd > /dev/null

fi

# ccache_version=3.3.3

# wget -q https://www.samba.org/ftp/ccache/ccache-${ccache_version}.tar.xz
# tar xf ccache-${ccache_version}.tar.xz
# cd ccache-${ccache_version}
# ./configure --prefix=${OPENSHIFT_DATA_DIR}/usr
# time make -j4
# make install
# cd ..
# rm -f ccache-${ccache_version}.tar.xz
# rm -rf ccache-${ccache_version}
export PATH="${OPENSHIFT_DATA_DIR}/usr/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_DATA_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/
# export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M

mkdir -p ${CCACHE_DIR}
mkdir -p ${CCACHE_TEMPDIR}

ccache -s
ccache -z
ccache -s

cd ${OPENSHIFT_TMP_DIR}

php_version=7.1.0
rm -rf php-${php_version}
wget -q -nc http://jp2.php.net/get/php-${php_version}.tar.xz/from/this/mirror -O php-${php_version}.tar.xz
tar xf php-${php_version}.tar.xz
rm -f php-${php_version}.tar.xz
cd php-${php_version}
./configure --help > ${OPENSHIFT_LOG_DIR}/configure_php
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/usr \
 --with-apxs2=${OPENSHIFT_DATA_DIR}/usr/bin/apxs \
 --without-sqlite3 \
 --without-pdo-sqlite \
 --without-cdb \
 --without-pear \
 --with-curl \
 --disable-fileinfo \
 --disable-ipv6 \
 --enable-fpm \
 --enable-mbstring \
 --with-pdo-mysql \
 --disable-phar \
 | tee configure_php.log
# --disable-fileinfo
time make -j1 2>&1 | tee ${OPENSHIFT_LOG_DIR}/make_php.log
cd ..
rm -rf php-${php_version}

ccache -s

quota -s
echo "FINISH"
exit
