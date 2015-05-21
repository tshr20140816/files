#!/bin/bash

# distcc のサーバは3機従えておく 1機あたり2～4のプロセスを与える

if [ $# -ne 3 ]; then
    exit
fi
    
export app_uuid=${1}
export data_dir=${2}
export tmp_dir=${3}

if [ ! -f ${OPENSHIFT_DATA_DIR}/version_list ]; then
    exit
fi

set -x

echo "$(date +%Y/%m/%d" "%H:%M:%S) start"

# 多重起動チェック
while :
do
    if [ -e ${OPENSHIFT_TMP_DIR}/build_now ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) waitting"
        sleep 60s
        find ${OPENSHIFT_TMP_DIR} -name 'build_now' -type f -mmin +60 -print0 | xargs -0i rm -f {}
    else
        break
    fi
done

touch ${OPENSHIFT_TMP_DIR}/build_now

memory_fail_count=$(oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}')
echo "$(date +%Y/%m/%d" "%H:%M:%S) Memory Fail Count : ${memory_fail_count}"

# 作成済みファイルがあった場合削除
rm -f ${OPENSHIFT_DATA_DIR}/files/${app_uuid}_maked_*

# makeターゲットのバージョン取得
while read LINE
do
    product=$(echo "${LINE}" | awk '{print $1}')
    version=$(echo "${LINE}" | awk '{print $2}')
    eval "${product}"="${version}"
done < ${OPENSHIFT_DATA_DIR}/version_list

# 環境変数

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CC="ccache distcc gcc"
export CXX="ccache distcc g++"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
# ログ多すぎ
# export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M

# export CCACHE_PREFIX="distcc"

export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
# export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc.log
export DISTCC_LOG=/dev/null
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
tmp_string="$(cat ${OPENSHIFT_DATA_DIR}/distcc_hosts.txt)"
export DISTCC_HOSTS="${tmp_string}"

export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:${OPENSHIFT_DATA_DIR}/openssh/bin:$PATH"
export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem

export CFLAGS="-O2 -march=x86-64 -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

export HOME=${OPENSHIFT_DATA_DIR}

# 統計情報クリア
ccache -z

# ***** apache *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) apache"

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

rm -rf httpd-${apache_version}
rm -f httpd-${apache_version}.tar.bz2

cp ${OPENSHIFT_DATA_DIR}/files/httpd-${apache_version}.tar.bz2 ./
if [ ! -f httpd-${apache_version}.tar.bz2 ]; then
    wget http://ftp.riken.jp/net/apache//httpd/httpd-${apache_version}.tar.bz2
fi
tar jxf httpd-${apache_version}.tar.bz2
pushd httpd-${apache_version} > /dev/null
./configure \
 --prefix=${data_dir}/apache \
 --mandir=${tmp_dir}/man \
 --docdir=${tmp_dir}/doc \
 --enable-mods-shared='all proxy'

# 3機がけ前提 1機あたり4プロセス
# time make -j$(grep -c -e processor /proc/cpuinfo)
distcc_hosts_org=${DISTCC_HOSTS}
tmp_string=$(echo ${DISTCC_HOSTS} | sed -e "s|/2:|/4:|g")
export DISTCC_HOSTS="${tmp_string}"
time make -j12
export DISTCC_HOSTS=${distcc_hosts_org}
popd > /dev/null
ccache -s
rm -f ${app_uuid}_maked_httpd-${apache_version}.tar.bz2
time tar jcf ${app_uuid}_maked_httpd-${apache_version}.tar.bz2 httpd-${apache_version}
mv -f ${app_uuid}_maked_httpd-${apache_version}.tar.bz2 ${OPENSHIFT_DATA_DIR}/files/
rm -f ${app_uuid}_maked_httpd-${apache_version}.tar.xz
# time tar Jcf ${app_uuid}_maked_httpd-${apache_version}.tar.xz httpd-${apache_version}
# mv -f ${app_uuid}_maked_httpd-${apache_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
rm -rf httpd-${apache_version}
rm -f httpd-${apache_version}.tar.bz2
popd > /dev/null

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
./configure \
 --prefix=${data_dir}/libmemcached \
 --mandir=${tmp_dir}/man \
 --docdir=${tmp_dir}/doc

# 3機がけ前提 1機あたり2プロセス
# time make -j$(grep -c -e processor /proc/cpuinfo)
time make -j6
popd > /dev/null
ccache -s
rm -f ${app_uuid}_maked_libmemcached-${libmemcached_version}.tar.xz
time tar Jcf ${app_uuid}_maked_libmemcached-${libmemcached_version}.tar.xz libmemcached-${libmemcached_version}
mv -f ${app_uuid}_maked_libmemcached-${libmemcached_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
rm -rf libmemcached-${libmemcached_version}
rm -f libmemcached-${libmemcached_version}.tar.gz

popd > /dev/null

# ***** ruby (rbenv) *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) ruby"

rm -rf ${OPENSHIFT_DATA_DIR}.gem
rm -rf ${OPENSHIFT_DATA_DIR}.rbenv

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -f rbenv-installer
wget https://raw.github.com/Seppone/openshift-rbenv-installer/master/bin/rbenv-installer
bash rbenv-installer
rm rbenv-installer
popd > /dev/null

path_old="$PATH"
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"

# https://github.com/sstephenson/ruby-build#special-environment-variables
export RUBY_CFLAGS="${CFLAGS}"
export CONFIGURE_OPTS="--disable-install-doc --mandir=${OPENSHIFT_TMP_DIR}/man --docdir=${OPENSHIFT_TMP_DIR}/doc --infodir=${OPENSHIFT_TMP_DIR}/info"
# 3機がけ前提 1機あたり4プロセス
# export MAKE_OPTS="-j $(grep -c -e processor /proc/cpuinfo)"
distcc_hosts_org=${DISTCC_HOSTS}
tmp_string=$(echo ${DISTCC_HOSTS} | sed -e "s|/2:|/4:|g")
export DISTCC_HOSTS="${tmp_string}"
export MAKE_OPTS="-j 12"
time rbenv install -v ${ruby_version}
unset RUBY_CFLAGS
unset CONFIGURE_OPTS
unset MAKE_OPTS
export DISTCC_HOSTS=${distcc_hosts_org}

ccache -s

unset RBENV_ROOT
unset GEM_HOME
export PATH="${path_old}"

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
find ./.rbenv/ -name '*' -type f -print0 | xargs -0i sed -i -e "s|${OPENSHIFT_DATA_DIR}|${data_dir}|g" {}
rm -f ${app_uuid}_maked_ruby_${ruby_version}_rbenv.tar.xz
time tar Jcf ${app_uuid}_maked_ruby_${ruby_version}_rbenv.tar.xz ./.rbenv
mv -f ${app_uuid}_maked_ruby_${ruby_version}_rbenv.tar.xz ${OPENSHIFT_DATA_DIR}/files/
popd > /dev/null

rm -rf ${OPENSHIFT_DATA_DIR}.rbenv

# ***** tcl *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) tcl"

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

rm -rf tcl${tcl_version}
rm -f tcl${tcl_version}-src.tar.gz

cp ${OPENSHIFT_DATA_DIR}/files/tcl${tcl_version}-src.tar.gz ./
if [ ! -f tcl${tcl_version}-src.tar.gz ]; then
    wget http://prdownloads.sourceforge.net/tcl/tcl${tcl_version}-src.tar.gz
fi
tar xfz tcl${tcl_version}-src.tar.gz

pushd ${OPENSHIFT_TMP_DIR}/tcl${tcl_version}/unix > /dev/null
./configure \
 --mandir=${tmp_dir}/man \
 --disable-symbols \
 --prefix=${data_dir}/tcl

# 3機がけ前提 1機あたり2プロセス
# time make -j2 -l3
time make -j6
popd > /dev/null
ccache -s
rm -f ${app_uuid}_maked_tcl${tcl_version}.tar.xz
time tar Jcf ${app_uuid}_maked_tcl${tcl_version}.tar.xz tcl${tcl_version}
mv -f ${app_uuid}_maked_tcl${tcl_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
rm -rf tcl${tcl_version}
rm -f tcl${tcl_version}-src.tar.gz
popd > /dev/null

memory_fail_count=$(oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}')
echo "$(date +%Y/%m/%d" "%H:%M:%S) Memory Fail Count : ${memory_fail_count}"

# ***** delegate *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) delegate"

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

rm -rf delegate${delegate_version}
rm -f delegate${delegate_version}.tar.gz

cp ${OPENSHIFT_DATA_DIR}/files/delegate${delegate_version}.tar.gz ./
if [ ! -f delegate${delegate_version}.tar.gz ]; then
    wget http://www.delegate.org/anonftp/DeleGate/delegate${delegate_version}.tar.gz
fi
tar xfz delegate${delegate_version}.tar.gz

# CC="ccache gcc"
# ccache gcc -DMKMKMK -DDEFCC=\"ccache gcc\" -I../gen -I../include -O2 -march=native -pipe -fomit-frame-pointer -s -Llib mkmkmk.c -o mkmkmk.exe
# gcc: gcc": No such file or directory
# <command-line>: warning: missing terminating " character
    
pushd ${OPENSHIFT_DATA_DIR}/ccache/bin > /dev/null
ln -s ccache cc
ln -s ccache gcc
popd > /dev/null
unset CC
unset CXX

pushd ${OPENSHIFT_TMP_DIR}/delegate${delegate_version} > /dev/null
time make -j$(grep -c -e processor /proc/cpuinfo) ADMIN=user@rhcloud.local
mkdir -p ${OPENSHIFT_TMP_DIR}/delegate${delegate_version}_backup/src/builtin/icons/ysato
cp src/delegated ${OPENSHIFT_TMP_DIR}/delegate${delegate_version}_backup/src/
cp src/builtin/icons/ysato/*.gif ${OPENSHIFT_TMP_DIR}/delegate${delegate_version}_backup/src/builtin/icons/ysato/
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -rf ./delegate${delegate_version}
mv delegate${delegate_version}_backup delegate${delegate_version}
popd > /dev/null
ccache -s
pushd ${OPENSHIFT_DATA_DIR}/ccache/bin > /dev/null
unlink cc
unlink gcc
popd > /dev/null
export CC="ccache gcc"
export CXX="ccache g++"

rm -f ${app_uuid}_maked_delegate${delegate_version}.tar.xz
time tar Jcf ${app_uuid}_maked_delegate${delegate_version}.tar.xz delegate${delegate_version}
mv -f ${app_uuid}_maked_delegate${delegate_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
rm -rf delegate${delegate_version}
rm -f delegate${delegate_version}.tar.gz
popd > /dev/null

rm -f ${OPENSHIFT_TMP_DIR}/build_now

echo "$(date +%Y/%m/%d" "%H:%M:%S) finish"
