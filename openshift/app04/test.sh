#!/bin/bash

# 1015

set -x

quota -s

cd /tmp

cat << '__HEREDOC__' > squid.conf
acl myhost src __OPENSHIFT_PHP_IP__/32

acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 443
acl CONNECT method CONNECT
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports

http_access allow myhost manager
http_access deny manager

http_access allow myhost

http_access deny all

http_port 33128

dns_nameservers 8.8.8.8

cache_dir ufs /var/lib/openshift/554b6b37e0b8cda2a300005d/app-root/data//squid/var/cache/squid 100 16 256
coredump_dir /var/lib/openshift/554b6b37e0b8cda2a300005d/app-root/data//squid/var/cache/squid

refresh_pattern ^ftp:		1440	20%	10080
refresh_pattern ^gopher:	1440	0%	1440
refresh_pattern -i (/cgi-bin/|\?) 0	0%	0
refresh_pattern .		0	20%	4320

__HEREDOC__
sed -i -e "s|__OPENSHIFT_PHP_IP__|${OPENSHIFT_PHP_IP}|g" squid.conf
cat squid.conf

ls -lang ${OPENSHIFT_DATA_DIR}/squid/var/run/
tree ${OPENSHIFT_DATA_DIR}/squid/var/run/
ps ax | grep squid
tree ${OPENSHIFT_DATA_DIR}/squid/var/logs/
${OPENSHIFT_DATA_DIR}/squid/sbin/squid -h
cat /var/lib/openshift/554b6b37e0b8cda2a300005d/app-root/data//squid/var/logs/cache.log
rm /var/lib/openshift/554b6b37e0b8cda2a300005d/app-root/data//squid/var/logs/cache.log
# ${OPENSHIFT_DATA_DIR}/squid/sbin/squid -a 33128 -k restart 2>&1
${OPENSHIFT_DATA_DIR}/squid/sbin/squid -kparse -f/tmp/squid.conf
${OPENSHIFT_DATA_DIR}/squid/sbin/squid -f/tmp/squid.conf
cat /var/lib/openshift/554b6b37e0b8cda2a300005d/app-root/data//squid/var/logs/cache.log
tree ${OPENSHIFT_DATA_DIR}/squid/var/run/
${OPENSHIFT_DATA_DIR}/squid/sbin/squid -kshutdown

cat /var/lib/openshift/554b6b37e0b8cda2a300005d/app-root/data//squid/var/logs/cache.log
exit

# tree ${OPENSHIFT_DATA_DIR}/squid
cp ${OPENSHIFT_DATA_DIR}/squid/etc/* ${OPENSHIFT_LOG_DIR}

exit

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
rm -rf ${CCACHE_TEMPDIR}
mkdir -p ${CCACHE_TEMPDIR}
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_NLEVELS=3
export CCACHE_MAXSIZE=300M
export CCACHE_COMPILERCHECK=none
export CC="ccache gcc"
export CXX="ccache g++"

ccache --show-stats
ccache --zero-stats 

cd /tmp

# rm -f squid-3.5.7.tar.xz
rm -rf squid-3.5.7

if [ ! -f squid-3.5.7.tar.xz ]; then
    wget http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.7.tar.xz
fi

# tar Jxf squid-3.5.7.tar.xz
if [ -f squid_src.tar.xz ]; then
  tar Jxf squid_src.tar.xz
else
  tar Jxf squid-3.5.7.tar.xz
fi

cd squid-3.5.7

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

# ./configure --help

if [ ! -f /tmp/squid_src.tar.xz ]; then
 time ./configure --prefix=${OPENSHIFT_DATA_DIR}/squid \
  --mandir=/tmp/gomi \
  --infodir=/tmp/gomi \
  --docdir=/tmp/gomi \
  --disable-dependency-tracking \
  --enable-shared \
  --enable-static=no \
  --enable-fast-install \
  --disable-icap-client \
  --disable-wccp \
  --disable-wccpv2 \
  --disable-snmp \
  --disable-eui \
  --disable-htcp \
  --disable-devpoll \
  --disable-ipv6 \
  --disable-auto-locale
fi

cd ..
if [ ! -f squid_src.tar.xz ]; then
  tar Jcf squid_src.tar.xz squid-3.5.7
fi

cd squid-3.5.7

time make -j4

time make install
