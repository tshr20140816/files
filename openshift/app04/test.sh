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

ccache -z

set -x

# ***** distcc *****

distcc_version=3.1

# rm -f ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version}.tar.bz2
# rm -rf ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version}
# rm -rf ${OPENSHIFT_DATA_DIR}/distcc

# pushd ${OPENSHIFT_TMP_DIR} > /dev/null
# wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2 > /dev/null 2>&1
# tar jxf distcc-${distcc_version}.tar.bz2
# popd > /dev/null
# pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
# ./configure \
#  --prefix=${OPENSHIFT_DATA_DIR}/distcc \
#  --mandir=${OPENSHIFT_TMP_DIR}/man > /dev/null 2>&1
# time make -j$(grep -c -e processor /proc/cpuinfo) > /dev/null 2>&1
# make install > /dev/null 2>&1
# popd > /dev/null

ls ${OPENSHIFT_DATA_DIR}/distcc

export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
pushd ${OPENSHIFT_DATA_DIR}/distcc > /dev/null
export DISTCC_HOSTS="@${OPENSHIFT_APP_DNS}/1"

ps auwx | grep distccd
lsof | grep distccd
kill $(ps auwx 2>/dev/null | grep distccd | grep ${OPENSHIFT_APP_UUID} | grep -v grep | awk '{print $2}')

rm -f ${OPENSHIFT_LOG_DIR}/distccd.log
touch ${OPENSHIFT_LOG_DIR}/distccd.log
# distccd --daemon --listen ${OPENSHIFT_PHP_IP} --jobs 1 --port 33632 \
# --allow 0.0.0.0/0 --log-file=${OPENSHIFT_LOG_DIR}/distccd.log --verbose --log-stderr
# Warning: --user is ignored when distccd is not run by root
popd > /dev/null

# ***** openssh *****

openssh_version=6.8p1

rm -f ${OPENSHIFT_TMP_DIR}/openssh-${openssh_version}.tar.gz
rm -rf ${OPENSHIFT_TMP_DIR}/openssh-${openssh_version}
rm -rf ${OPENSHIFT_DATA_DIR}/openssh

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/openssh-${openssh_version}.tar.gz > /dev/null 2>&1
tar xfz openssh-${openssh_version}.tar.gz
popd > /dev/null
export CC=distcc
export DISTCC_DIR=${OPENSHIFT_TMP_DIR}/.distcc
pushd ${OPENSHIFT_TMP_DIR}/openssh-${openssh_version} > /dev/null
./configure --prefix=${OPENSHIFT_DATA_DIR}/openssh > /dev/null 2>&1
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1
make install
popd > /dev/null

ls ${OPENSHIFT_DATA_DIR}/openssh
