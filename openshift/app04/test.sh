#!/bin/bash

echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

cd /tmp
if [ ! -e ${OPENSHIFT_DATA_DIR}/ccache ]; then
    if [ ! -f ccache-3.2.1.tar.xz ]; then
        wget https://files3-20150207.rhcloud.com/files/ccache-3.2.1.tar.xz
    fi
    tar xfz ccache-3.2.1.tar.xz
    cd ccache-3.2.1
    CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s" CXXFLAGS="-O2 -march=native -pipe" \
     ./configure --prefix=${OPENSHIFT_DATA_DIR}/ccache --mandir=/tmp/man --docdir=/tmp/doc
    make
    make install
fi

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_MAXSIZE=300M
export CCACHE_BASEDIR=${OPENSHIFT_HOME_DIR}

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

ccache -C
ccache -z

cd /tmp
if [ ! -f php-5.6.8.tar.xz ]; then
    wget https://files3-20150207.rhcloud.com/files/php-5.6.8.tar.xz
fi
rm -rf php-5.6.8
tar xfz php-5.6.8.tar.xz

date >> test.log
cd php-5.6.8
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/php \
--mandir=${OPENSHIFT_TMP_DIR}/man \
--docdir=${OPENSHIFT_TMP_DIR}/doc \
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
--with-gettext=${OPENSHIFT_DATA_DIR}/php
date >> test.log

(time make) >> test.log 2>&1
date >> test.log

ccache -s >> test.log
