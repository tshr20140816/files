#!/bin/bash

[ $# -eq 3 ] || exit
[ -f ${OPENSHIFT_DATA_DIR}/version_list ] || exit

export app_uuid=${1}
export data_dir=${2}
export tmp_dir=${3}

set -x

echo "$(date +%Y/%m/%d" "%H:%M:%S) start"

# 多重起動チェック
while :
do
    if [ -f ${OPENSHIFT_TMP_DIR}/build_now ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) waitting"
        sleep 60s
        find ${OPENSHIFT_TMP_DIR} -name 'build_now' -type f -mmin +60 -print0 | xargs -0i rm -f {}
    else
        break
    fi
done

quota -s > ${OPENSHIFT_LOG_DIR}/quota.txt

touch ${OPENSHIFT_TMP_DIR}/build_now

lsof -i

memory_fail_count=$(oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}')
echo "$(date +%Y/%m/%d" "%H:%M:%S) Memory Fail Count : ${memory_fail_count}"

# 作成済みファイルがあった場合削除
rm -f ${OPENSHIFT_DATA_DIR}/files/${app_uuid}_maked_*
rm -f ${OPENSHIFT_LOG_DIR}/ccache.log

# makeターゲットのバージョン取得
while read LINE
do
    product=$(echo "${LINE}" | awk '{print $1}')
    version=$(echo "${LINE}" | awk '{print $2}')
    eval "${product}"="${version}"
done < ${OPENSHIFT_DATA_DIR}/version_list

# 環境変数

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
# export PATH="${OPENSHIFT_DATA_DIR}/xz/bin:$PATH"

# ld.gold があればそれを使う
# https://github.com/accursoft/Haskell-Cloud/blob/master/.openshift/build
if [ -f ${OPENSHIFT_DATA_DIR}/files/ld.gold ]; then
    rm -rf ${OPENSHIFT_TMP_DIR}/local
    mkdir -p ${OPENSHIFT_TMP_DIR}/local/bin
    cp ${OPENSHIFT_DATA_DIR}/files/ld.gold ${OPENSHIFT_TMP_DIR}/local/bin/
    chmod +x ${OPENSHIFT_TMP_DIR}/local/bin/ld.gold
    export PATH="${OPENSHIFT_TMP_DIR}/local/bin:$PATH"
    export LD=ld.gold
fi
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_MAXSIZE=300M
# ログ多すぎ
# export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_LOGFILE=/dev/null

# export CFLAGS="-O2 -march=core2 -pipe -fomit-frame-pointer -s"
export CFLAGS="-O2 -march=core2 -maes -mavx -mcx16 -mpclmul -mpopcnt -msahf"
export CFLAGS="${CFLAGS} -msse -msse2 -msse3 -msse4 -msse4.1 -msse4.2 -mssse3 -mtune=generic"
export CFLAGS="${CFLAGS} -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

ccache --show-stats
ccache --zero-stats
ccache --print-config

# ***** libmemcached *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached"

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

rm -rf libmemcached-${libmemcached_version}
rm -f libmemcached-${libmemcached_version}.tar.gz

cp ${OPENSHIFT_DATA_DIR}/files/libmemcached-${libmemcached_version}.tar.gz ./
if [ ! -f libmemcached-${libmemcached_version}.tar.gz ]; then
    wget https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz
fi
tar zxf libmemcached-${libmemcached_version}.tar.gz
pushd libmemcached-${libmemcached_version} > /dev/null
./configure --help
./configure \
 --prefix=${data_dir}/libmemcached \
 --mandir=${tmp_dir}/man \
 --docdir=${tmp_dir}/doc \
 --infodir=${tmp_dir}/info \
 --disable-dependency-tracking \
 --disable-sasl
# --enable-jobserver=4

time make
popd > /dev/null
ccache --show-stats
rm -f ${app_uuid}_maked_libmemcached-${libmemcached_version}.tar.xz
time tar Jcf ${app_uuid}_maked_libmemcached-${libmemcached_version}.tar.xz libmemcached-${libmemcached_version}
mv -f ${app_uuid}_maked_libmemcached-${libmemcached_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
rm -rf libmemcached-${libmemcached_version}
rm -f libmemcached-${libmemcached_version}.tar.gz

popd > /dev/null

rm -f ${OPENSHIFT_TMP_DIR}/build_now

quota -s > ${OPENSHIFT_LOG_DIR}/quota.txt

echo "$(date +%Y/%m/%d" "%H:%M:%S) finish"
