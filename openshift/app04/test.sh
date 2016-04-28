#!/bin/bash

echo "1538"

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


pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -q ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.bz2
tar xf pcre-8.38.tar.bz2
rm -f pcre-8.38.tar.bz2
pushd pcre-8.38 > /dev/null
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr --mandir=${OPENSHIFT_TMP_DIR}/gomi --docdir=${OPENSHIFT_TMP_DIR}/gomi --enable-static=no
time make -j4
make install
popd > /dev/null
rm -rf pcre-8.38
popd > /dev/null
    
cd ${OPENSHIFT_TMP_DIR}
tmp_dir=$(mktemp -d tmp.XXXXX)
cd ${tmp_dir}
wget -q http://ftp.yz.yamagata-u.ac.jp/pub/network/apache//httpd/httpd-2.4.20.tar.bz2
tar xf httpd-2.4.20.tar.bz2
wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-1.5.2.tar.bz2
tar xf apr-1.5.2.tar.bz2
mv -f ./apr-1.5.2 ./httpd-2.4.20/srclib/apr
wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-util-1.5.4.tar.bz2
tar xf apr-util-1.5.4.tar.bz2
mv -f ./apr-util-1.5.4 ./httpd-2.4.20/srclib/apr-util
rm -f *.bz2

cd httpd-2.4.20
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
 --disable-vhost-alias

time make -j4
make install

cd /tmp
rm -rf ${tmp_dir} gomi

tree -a ${OPENSHIFT_DATA_DIR}/usr

quota -s
echo "FINISH"
exit
