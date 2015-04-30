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
i=0

url="https://tshrapp9.appspot.com/dummy"
set +x
while read LINE
do
    i=$((i+1))
    log_String=$(echo ${LINE} | tr " " "_" | perl -MURI::Escape -lne 'print uri_escape($_)')
    query_string="server=${OPENSHIFT_GEAR_DNS}&file=cron_minutely&log=${i}_${log_String}"
    # nohup wget -b --spider -q -o /dev/null "${url}?${query_string}" > /dev/null 2>&1
    wget --spider -q -o /dev/null "${url}?${query_string}" > /dev/null 2>&1
done < nohup.log
set -x

date
ps aux | wc -l
