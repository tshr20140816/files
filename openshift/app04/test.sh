#!/bin/bash

set -x

quota -s

export PATH="${OPENSHIFT_TMP_DIR}/local/bin:$PATH"
export LD_LIBRARY_PATH="${OPENSHIFT_TMP_DIR}/local/lib:$LD_LIBRARY_PATH"
export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

cd /tmp
mkdir work
cd work

wget http://ftp.gnome.org/pub/GNOME/sources/glib/2.12/glib-2.12.13.tar.bz2
tar jxf glib-2.12.13.tar.bz2
cd glib-2.12.13
./configure --help
time ./configure --prefix=/tmp/local --mandir=/tmp/gomi --infodir=/tmp/gomi
time make -j4
make install

wget http://ftp.gtk.org/pub/gtk/v2.10/gtk+-2.10.14.tar.bz2
time tar jxf gtk+-2.10.14.tar.bz2
cd gtk+-2.10.14
./configure --help
time ./configure --prefix=/tmp/local --mandir=/tmp/gomi --infodir=/tmp/gomi
time make -j4
make install

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
--enable-static \
--with-windows-version=501

quota -s
cd /tmp
rm -rf work

exit

rm -rf work

ls -lang ${OPENSHIFT_DATA_DIR}

exit

export PATH="${OPENSHIFT_TMP_DIR}/local/bin:$PATH"
export LD_LIBRARY_PATH="${OPENSHIFT_TMP_DIR}/local/lib:$LD_LIBRARY_PATH"
export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

cd /tmp

mkdir work
cd work

wget http://ftp.gtk.org/pub/gtk/v2.0/atk-1.0.3.tar.bz2
tar jxf atk-1.0.3.tar.bz2
cd atk-1.0.3
./configure --help
time ./configure --prefix=/tmp/local --mandir=/tmp/gomi --infodir=/tmp/gomi --enable-shared --disable-static
time make -j4
make install

wget http://ftp.gtk.org/pub/gtk/v2.0/pango-1.0.5.tar.bz2
tar jxf pango-1.0.5.tar.bz2
cd pango-1.0.5
./configure --help
time ./configure --prefix=/tmp/local --mandir=/tmp/gomi --infodir=/tmp/gomi
time make -j4
make install

wget http://ftp.gtk.org/pub/gtk/v2.0/gtk+-2.0.9.tar.bz2
tar jxf gtk+-2.0.9.tar.bz2
cd gtk+-2.0.9
./configure --help
time ./configure --prefix=/tmp/local --mandir=/tmp/gomi --infodir=/tmp/gomi
time make -j4
make install

cd /tmp
rm -rf work
rm -rf gomi
tree local
exit

export PATH="${OPENSHIFT_TMP_DIR}/local/bin:$PATH"
export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

mkdir work
cd work

wget http://ftp.gnome.org/pub/GNOME/sources/glib/2.0/glib-2.0.7.tar.bz2
tar jxf glib-2.0.7.tar.bz2
cd glib-2.0.7
./configure --help
time ./configure --prefix=/tmp/local --mandir=/tmp/gomi --infodir=/tmp/gomi
time make -j4
make install

cd /tmp
rm -rf work
rm -rf gomi
exit

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

cd /tmp

mkdir work
cd work
wget http://pkg-config.freedesktop.org/releases/pkgconfig-0.18.tar.gz
tar zxf pkgconfig-0.18.tar.gz
cd pkgconfig-0.18
./configure --help
time ./configure --prefix=/tmp/local --mandir=/tmp/gomi --infodir=/tmp/gomi
time make -j4
make install
tree /tmp/local

cd /tmp
rm -rf work
rm -rf gomi
exit

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
--enable-static \
--with-windows-version=501

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
