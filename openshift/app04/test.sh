#!/bin/bash

echo "1152"

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

quota -s

# -----

cd /tmp
rm -rf 20160425
rm -rf gomi
rm -rf ${OPENSHIFT_DATA_DIR}/usr

# -----

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd /tmp
mkdir 20160425
cd 20160425
wget -q ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.bz2
tar xf pcre-8.38.tar.bz2
cd pcre-8.38
# ls -lang
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr --mandir=${OPENSHIFT_TMP_DIR}/gomi/man --docdir=${OPENSHIFT_TMP_DIR}/gomi/doc
time make -j4
make install

wget -q http://ftp.yz.yamagata-u.ac.jp/pub/network/apache//httpd/httpd-2.4.20.tar.bz2
tar xf httpd-2.4.20.tar.bz2
wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-1.5.2.tar.bz2
tar xf apr-1.5.2.tar.bz2
# cp -Rp ./apr-1.5.2 ./httpd-2.4.20/srclib/apr
mv -f ./apr-1.5.2 ./httpd-2.4.20/srclib/apr
wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-util-1.5.4.tar.bz2
tar xf apr-util-1.5.4.tar.bz2
mv -f ./apr-util-1.5.4 ./httpd-2.4.20/srclib/apr-util
rm -f *.bz2

cd httpd-2.4.20
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr --mandir=${OPENSHIFT_TMP_DIR}/gomi/man --docdir=${OPENSHIFT_TMP_DIR}/gomi/doc \
 -enable-mods-shared='all proxy' --with-mpm=event --with-pcre-dir=${OPENSHIFT_DATA_DIR}/usr
time make -j4

cd ..
wget -q http://us1.php.net/get/php-7.0.5.tar.xz/from/this/mirror -O php-7.0.5.tar.xz
tar xf php-7.0.5.tar.xz
cd php-7.0.5
./configure --help

quota -s
echo "FINISH"
exit
