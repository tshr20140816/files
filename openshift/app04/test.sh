#!/bin/bash

set -x

quota -s

cd /tmp
mkdir work
cd work
wget http://ftp.mozilla.org/pub/mozilla.org/calendar/sunbird/releases/1.0b1/source/sunbird-1.0b1.source.tar.bz2
time tar jxf sunbird-1.0b1.source.tar.bz2
rm sunbird-1.0b1.source.tar.bz2
cd comm-1.9.1
./configure --help
time ./configure \
--disable-accessibility \
--disable-activex \
--disable-activex-scripting \
--disable-auto-deps \
--disable-composer \
--disable-crypto \
--disable-dbus \
--disable-feeds \
--disable-glibtest \
--disable-gnomeui \
--disable-gnomevfs \
--disable-inspector-apis \
--disable-installer \
--disable-jsd \
--disable-jsloader \
--disable-ldap \
--disable-logging \
--disable-mailnews \
--disable-md \
--disable-negotiateauth \
--disable-ogg \
--disable-oji \
--disable-optimize \
--disable-parental-controls \
--disable-pedantic \
--disable-permissions \
--disable-plugins \
--disable-pref-extensions \
--disable-printing \
--disable-profile-guided-optimization \
--disable-profilelocking \
--disable-rdf \
--disable-tests \
--disable-universalchardet \
--disable-updater \
--disable-view-source \
--disable-vista-sdk-requirements \
--disable-wave \
--disable-xpcom-fastload \
--disable-xpcom-obsolete \
--disable-xpconnect-idispatch \
--disable-xpfe-components \
--disable-xpinstall \
--disable-xtf \
--disable-xul \
--disable-zipwriter \
--enable-application=calendar \
--with-windows-version=601

quota -s
cd /tmp
rm -rf work

exit

cd /tmp

# cat ${OPENSHIFT_DATA_DIR}/sphinx/etc/*

mkdir work
cd work

wget http://ftp.riken.jp/net/apache//httpd/httpd-2.2.31.tar.bz2
tar jxf httpd-2.2.31.tar.bz2
time tar zcf test.tar.gz httpd-2.2.31
time tar jcf test.tar.bz2 httpd-2.2.31

cd /tmp
rm -rf work

exit

cd /tmp

export CFLAGS="-O2 ${cflag_data} -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"
    
sphinx_version=2.2.10

rm -rf sphinx-${sphinx_version}-release
rm sphinx-${sphinx_version}-release.tar.gz*

wget http://sphinxsearch.com/files/sphinx-${sphinx_version}-release.tar.gz
tar zxf sphinx-${sphinx_version}-release.tar.gz

cd sphinx-${sphinx_version}-release
./configure --help
./configure \
     --prefix=${OPENSHIFT_DATA_DIR}/sphinx \
     --mandir=/tmp/gomi \
     --infodir=/tmp/gomi \
     --docdir=/tmp/gomi \
     --disable-dependency-tracking \
     --disable-id64 \
     --with-mysql \
     --without-syslog \
     --without-unixodbc
     
time make
make install

cd /tmp

rm -rf sphinx-${sphinx_version}-release
rm -f sphinx-${sphinx_version}-release.tar.gz*

tree ${OPENSHIFT_DATA_DIR}/sphinx
