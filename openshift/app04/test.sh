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

# export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
# export CC="ccache gcc"
# export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_MAXSIZE=300M
export CCACHE_BASEDIR=${OPENSHIFT_HOME_DIR}

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

# ccache -z

set -x

cd /tmp

# ***** distcc *****

distcc_version=3.1

rm -f distcc-${distcc_version}.tar.bz2
rm -f distcc.html
wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2
wget https://code.google.com/p/distcc/downloads/detail?name=distcc-${distcc_version}.tar.bz2 -O distcc.html
tarball_sha1=$(sha1sum distcc-${distcc_version}.tar.bz2 | cut -d ' ' -f 1)
echo ${tarball_sha1}
cat distcc.html | grep sha1 > distcc.html
perl -pi -e 's/<.+?>//g' distcc.html
perl -pi -e 's/ //g' distcc.html
test_data=$(cat distcc.html)
echo "${test_data}"

ls -lang
