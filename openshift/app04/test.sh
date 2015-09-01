#!/bin/bash

set -x

quota -s

cd /tmp

rm -f squid*

wget http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.7.tar.xz

tar Jxf squid-3.5.7.tar.xz

cd squid-3.5.7

./configure --help

./configure --prefix=${OPENSHIFT_DATA_DIR}/squid \
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
