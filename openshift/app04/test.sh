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

expect_version=5.45

rm -f expect${expect_version}.tar.gz
rm -rf expect${expect_version}

openssh_version=6.8p1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/openssh-${openssh_version}.tar.gz
tar xfz openssh-${openssh_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/openssh-${openssh_version} > /dev/null
./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/openssh \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

tree ${OPENSHIFT_DATA_DIR}/openssh
