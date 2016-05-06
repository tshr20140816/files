#!/bin/bash

export TZ=JST-9

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

# ***** pcre *****

pcre_version=8.38
if [ ! -f ${OPENSHIFT_DATA_DIR}/usr/lib/libpcre.so ]; then
    pushd ${OPENSHIFT_TMP_DIR} > /dev/null
    wget -q ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${pcre_version}.tar.bz2
    tar xf pcre-${pcre_version}.tar.bz2
    rm -f pcre-${pcre_version}.tar.bz2
    pushd pcre-${pcre_version} > /dev/null
    ./configure --help
    ./configure --prefix=${OPENSHIFT_DATA_DIR}/usr --mandir=${OPENSHIFT_TMP_DIR}/gomi --docdir=${OPENSHIFT_TMP_DIR}/gomi --enable-static=no
    time make -j4
    make install
    popd > /dev/null
    rm -rf pcre-${pcre_version}
    popd > /dev/null
fi

# ***** apache *****

apache_version=2.4.20
apr_version=1.5.2
aprutil_version=1.5.4
if [ ! -f ${OPENSHIFT_DATA_DIR}/usr/bin/httpd ]; then
    pushd ${OPENSHIFT_TMP_DIR} > /dev/null
    wget -q http://ftp.yz.yamagata-u.ac.jp/pub/network/apache//httpd/httpd-${apache_version}.tar.bz2
    tar xf httpd-${apache_version}.tar.bz2
    wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-${apr_version}.tar.bz2
    tar xf apr-${apr_version}.tar.bz2
    mv -f ./apr-${apr_version} ./httpd-${apache_version}/srclib/apr
    wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-util-${aprutil_version}.tar.bz2
    tar xf apr-util-${aprutil_version}.tar.bz2
    mv -f ./apr-util-${aprutil_version} ./httpd-${apache_version}/srclib/apr-util
    rm -f *.bz2

    pushd httpd-${apache_version} > /dev/null
    ./configure --help
    ./configure --prefix=${OPENSHIFT_DATA_DIR}/usr --mandir=${OPENSHIFT_TMP_DIR}/gomi --docdir=${OPENSHIFT_TMP_DIR}/gomi \
     --enable-mods-shared='all proxy' --with-mpm=event --with-pcre=${OPENSHIFT_DATA_DIR}/usr \
     --disable-authn-anon \
     --disable-authn-dbd \
     --disable-authn-dbm \
     --disable-authz-dbm \
     --disable-authz-groupfile \
     --disable-authz-owner \
     --disable-dbd \
     --disable-info \
     --disable-log-forensic \
     --disable-proxy-ajp \
     --disable-proxy-balancer \
     --disable-proxy-ftp \
     --disable-proxy-scgi \
     --disable-speling \
     --disable-status \
     --disable-userdir \
     --disable-version \
     --disable-vhost-alias \
     --disable-dialup

    time make -j4
    make install
    popd > /dev/null
    rm -rf httpd-${apache_version}
    popd > /dev/null
    rm -rf ${OPENSHIFT_DATA_DIR}/usr/manual
fi

cd ${OPENSHIFT_DATA_DIR}/usr/htdocs
wget -q https://files.phpmyadmin.net/phpMyAdmin/4.4.15.5/phpMyAdmin-4.4.15.5-english.tar.bz2
tar xf phpMyAdmin-4.4.15.5-english.tar.bz2
mv -f phpMyAdmin-4.4.15.5-english phpmyadmin
rm -f phpMyAdmin-4.4.15.5-english.tar.bz2

cat << '__HEREDOC__' > phpmyadmin/config.inc.php

__HEREDOC__
