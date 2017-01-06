#!/bin/bash

echo "1458"

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
ls -lang $OPENSHIFT_REPO_DIR

quota -s

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd ${OPENSHIFT_TMP_DIR}

ls -al

# ccache_version=3.3.3

# wget -q https://www.samba.org/ftp/ccache/ccache-${ccache_version}.tar.xz
# tar xf ccache-${ccache_version}.tar.xz
# cd ccache-${ccache_version}
# ./configure --prefix=${OPENSHIFT_DATA_DIR}/usr
# time make -j4
# make install
# cd ..
# rm -f ccache-${ccache_version}.tar.xz
# rm -rf ccache-${ccache_version}
export PATH="${OPENSHIFT_DATA_DIR}/usr/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_DATA_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/
# export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M

mkdir -p ${CCACHE_DIR}
mkdir -p ${CCACHE_TEMPDIR}

ccache -s
ccache -z
ccache -s

cd ${OPENSHIFT_TMP_DIR}

php_version=7.1.0
rm -rf php-${php_version}
wget -q -nc http://jp2.php.net/get/php-${php_version}.tar.xz/from/this/mirror -O php-${php_version}.tar.xz
tar xf php-${php_version}.tar.xz
rm -f php-${php_version}.tar.xz
cd php-${php_version}
./configure --help > ${OPENSHIFT_LOG_DIR}/configure_php
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/usr \
 --disable-ipv6 \
 --disable-fileinfo \
 | tee configure_php.log
time make -j1 | tee ${OPENSHIFT_LOG_DIR}/make_php.log
cd ..
rm -rf php-${php_version}

ccache -s

quota -s
echo "FINISH"
exit
