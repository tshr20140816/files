#!/bin/bash

set -x

# *** apache ***

apache_version='2.2.29'

pushd ${OPENSHIFT_TMP_DIR}
wget http://ftp.riken.jp/net/apache//httpd/httpd-${apache_version}.tar.bz2
tarball_md5=$(md5sum httpd-${apache_version}.tar.bz2 | cut -d ' ' -f 1)
apache_md5=$(curl -Ls http://www.apache.org/dist/httpd/httpd-${apache_version}.tar.bz2.md5 | cut -d ' ' -f 1)
if [ "${tarball_md5}" != "${apache_md5}" ]; then
    rm httpd-${apache_version}.tar.bz2
    exit
fi

tar jxf httpd-${apache_version}.tar.bz2

CFLAGS="-O2 -march=native -pipe" CXXFLAGS="-O2 -march=native -pipe" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/apache \
--mandir=/tmp/man \
--docdir=/tmp/doc \
--enable-mods-shared='all proxy'

time make -j$(grep -c -e processor /proc/cpuinfo)

make install

cp conf/httpd.conf conf/httpd.conf.$(date '+%Y%m%d')

perl -pi -e 's/^Listen .+$/Listen $ENV{OPENSHIFT_DIY_IP}:8080/g' conf/httpd.conf
perl -pi -e 's/AllowOverride None/AllowOverride All/g' conf/httpd.conf

perl -pi -e 's/(^ *LogFormat.+$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^ *CustomLog.+$)/# $1/g' conf/httpd.conf

cat << '__HEREDOC__' >> conf/httpd.conf

LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
CustomLog "|/usr/sbin/rotatelogs -L logs/access_log logs/access_log.%Y%m%d 86400 540" combined
__HEREDOC__

/usr/bin/gear stop --trace
/usr/bin/gear start --trace

popd
