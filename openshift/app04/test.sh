#!/bin/bash

echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

# dummy

cd /tmp
if [ ! -e ${OPENSHIFT_DATA_DIR}/ccache ]; then
    if [ ! -f ccache-3.2.1.tar.xz ]; then
        wget https://files3-20150207.rhcloud.com/files/ccache-3.2.1.tar.xz
    fi
    tar Jxf ccache-3.2.1.tar.xz
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


cd /tmp
mkdir files
cd files

mirror_server="https://files3-20150207.rhcloud.com/files"

# ccache cache
wget -t1 ${mirror_server}/ccache_apache.tar.xz &
wget -t1 ${mirror_server}/ccache_php.tar.xz &
wget -t1 ${mirror_server}/ccache_libmemcached.tar.xz &
wget -t1 ${mirror_server}/ccache_delegate.tar.xz &
wget -t1 ${mirror_server}/ccache_ruby.tar.xz &
wget -t1 ${mirror_server}/ccache_tcl.tar.xz &
wget -t1 ${mirror_server}/ccache_passenger.tar.xz &
# wget -t1 ${mirror_server}/ccache.tar.xz

# ipa font
wget -t1 ${mirror_server}/ipagp${ipafont_version}.zip &
# webalizer
wget -t1 ${mirror_server}/webalizer-${webalizer_version}-src.tar.bz2 &
# ttrss
wget -t1 ${mirror_server}/${ttrss_version}.tar.gz &
# cacti
wget -t1 ${mirror_server}/cacti-${cacti_version}.tar.gz &
# tcl
wget -t1 ${mirror_server}/tcl${tcl_version}-src.tar.gz &
# expect
wget -t1 ${mirror_server}/expect${expect_version}.tar.gz &
# logrotate
wget -t1 ${mirror_server}/logrotate-${logrotate_version}.tar.gz &
# lynx
wget -t1 ${mirror_server}/lynx${lynx_version}.tar.gz &
# memcached
wget -t1 ${mirror_server}/memcached-${memcached_version}.tar.gz &
# memcached(php extension)
wget -t1 ${mirror_server}/memcached-${memcached_php_ext_version}.tgz &
# mURLin
wget -t1 ${mirror_server}/mURLin-${murlin_version}.tar.gz &
# fio
wget -t1 ${mirror_server}/fio-${fio_version}.tar.bz2 &
# Baikal
wget -t1 ${mirror_server}/baikal-flat-${baikal_version}.zip &
# CalDavZAP
wget -t1 ${mirror_server}/CalDavZAP_${caldavzap_version}.zip &
# phpicalendar
wget -t1 ${mirror_server}/phpicalendar-${phpicalendar_version}.tar.bz2 &
wait

ls -lang
