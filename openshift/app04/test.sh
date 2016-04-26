#!/bin/bash

echo "1337"

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
tmp_dir=$(mktemp -d tmp.XXXXX)
cd ${tmp_dir}
wget -q http://ftp.kddilabs.jp/infosystems/apache//httpd/httpd-2.2.31.tar.bz2
tar xf httpd-2.2.31.tar.bz2
cd httpd-2.2.31
./configure --help
.configure --prefix=${OPENSHIFT_DATA_DIR}/usr \
 --disable-imagemap \
 --disable-include \
 --enable-mods-shared='all proxy' \
 --disable-authn-anon \
 --disable-authn-dbm \
 --disable-authz-dbm \
 --disable-authz-groupfile \
 --disable-info \
 --disable-proxy-balancer \
 --disable-proxy-ftp \
 --disable-speling \
 --disable-status \
 --disable-userdir \
 --disable-version \
 --disable-vhost-alias \
 --disable-authn-dbd \
 --disable-dbd \
 --disable-log-forensic \
 --disable-proxy-ajp \
 --disable-proxy-scgi
time make -j4

cd /tmp
rm -rf ${tmp_dir}

quota -s
echo "FINISH"
exit
