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
rm -rf files
mkdir files 2> /dev/null
cd files

cat << '__HEREDOC__' > version_list
apache_version 2.2.29
baikal_version 0.2.7
cacti_version 0.8.8c
caldavzap_version 0.12.1
ccache_version 3.2.1
delegate_version 9.9.13
expect_version 5.45
fio_version 2.2.7
ipafont_version 00303
libmemcached_version 1.0.18
logrotate_version 3.8.8
lynx_version 2.8.7
memcached_php_ext_version 2.2.0
memcached_version 1.4.22
mrtg_version 2.17.4
murlin_version 0.2.4
php_version 5.6.8
phpicalendar_version 2.4_20100615
pigz_version 2.3.3
redmine_version 2.6.3
ruby_version 2.1.6
tcl_version 8.6.3
ttrss_version 1.15.3
webalizer_version 2.23-08
wordpress_version 4.1.2-ja
__HEREDOC__

while read LINE
do
    product=$(echo "${LINE}" | awk '{print $1}')
    version=$(echo "${LINE}" | awk '{print $2}')
    eval "${product}"="${version}"
done < version_list

mirror_server="https://files3-20150207.rhcloud.com/files"

echo "$(date)"

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
echo "$(date)"

ls -lang
