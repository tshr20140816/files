#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

cd /tmp
if [ ! -e ${OPENSHIFT_DATA_DIR}/ccache ]; then
    if [ ! -f ccache-3.2.1.tar.xz ]; then
        wget https://files3-20150207.rhcloud.com/files/ccache-3.2.1.tar.xz
    fi
    tar Jxf ccache-3.2.1.tar.xz
    cd ccache-3.2.1
    CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s" CXXFLAGS="-O2 -march=native -pipe" \
     ./configure --prefix=${OPENSHIFT_DATA_DIR}/ccache --mandir=/tmp/man --docdir=/tmp/doc
    make
    make install
fi

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_MAXSIZE=300M
export CCACHE_BASEDIR=${OPENSHIFT_HOME_DIR}

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

ccache -z

set -x

ls -lang /tmp

cd /tmp

[ ! -f cron_minutely.log.old ] && touch cron_minutely.log.old
cp -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log ./cron_minutely.log.new
diff --new-line-format='%L' --unchanged-line-format='' cron_minutely.log.old cron_minutely.log.new > diff_cron_minutely.log
mv -f cron_minutely.log.new cron_minutely.log.old
url="https://tshrapp9.appspot.com/dummy"
set +x
while read LINE
do
    log_String=$(echo ${LINE} | perl -MURI::Escape -lne 'print uri_escape($_)')
    query_string="server=${OPENSHIFT_GEAR_DNS}&file=cron_minutely&log=${log_String}"
    wget --spider -q "${url}?${query_string}" &
done < diff_cron_minutely.log
set -x
rm -f diff_cron_minutely.log

# dummy
