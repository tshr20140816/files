#!/bin/bash

if [ $# -ne 3 ]; then
    exit
fi

export app_uuid=${1}
export data_dir=${2}
export tmp_dir=${3}

date >> ${OPENSHIFT_LOG_DIR}/build_action.log

if [ ! -f ${OPENSHIFT_DATA_DIR}/version_list ]; then
    exit
fi

echo 'start' >> ${OPENSHIFT_LOG_DIR}/build_action.log

rm -f ${OPENSHIFT_DATA_DIR}/files/${host_name}_maked_*

while read LINE
do
    product=$(echo "${LINE}" | awk '{print $1}')
    version=$(echo "${LINE}" | awk '{print $2}')
    eval "${product}"="${version}"
done < ${OPENSHIFT_DATA_DIR}/version_list

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_MAXSIZE=300M

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

# ***** apache *****

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

time make -j$(grep -c -e processor /proc/cpuinfo)
popd > /dev/null
rm -f maked_httpd-${apache_version}.tar.xz
time tar Jcf ${app_uuid}_maked_httpd-${apache_version}.tar.xz httpd-${apache_version}
mv -f ${app_uuid}_maked_httpd-${apache_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
rm -rf httpd-${apache_version}

popd > /dev/null

# ***** libmemcached *****

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
 --prefix=${data_dir}/apache \
 --mandir=${tmp_dir}/man \
 --docdir=${tmp_dir}/doc

time make -j$(grep -c -e processor /proc/cpuinfo)
popd > /dev/null
rm -f maked_libmemcached-${libmemcached_version}.tar.xz
time tar Jcf ${app_uuid}_maked_libmemcached-${libmemcached_version}.tar.xz libmemcached-${libmemcached_version}
mv -f ${app_uuid}_maked_libmemcached-${libmemcached_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
rm -rf libmemcached-${libmemcached_version}

popd > /dev/null

# ***** delegate *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

rm -rf delegate${delegate_version}
rm -f delegate${delegate_version}.tar.gz

cp ${OPENSHIFT_DATA_DIR}/files/delegate${delegate_version}.tar.gz ./
if [ ! -f delegate${delegate_version}.tar.gz ]; then
    wget http://www.delegate.org/anonftp/DeleGate/delegate${delegate_version}.tar.gz
fi
tar xfz delegate${delegate_version}.tar.gz

pushd ${OPENSHIFT_DATA_DIR}/ccache/bin > /dev/null
ln -s ccache cc
ln -s ccache gcc
popd > /dev/null
unset CC
unset CXX

pushd ${OPENSHIFT_TMP_DIR}/delegate${delegate_version} > /dev/null
time make -j$(grep -c -e processor /proc/cpuinfo) ADMIN=user@rhcloud.local
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/ccache/bin > /dev/null
unlink cc
unlink gcc
popd > /dev/null
export CC="ccache gcc"
export CXX="ccache g++"

rm -f maked_delegate${delegate_version}.tar.xz
time tar Jcf ${app_uuid}_maked_delegate${delegate_version}.tar.xz delegate${delegate_version}
mv -f ${app_uuid}_maked_delegate${delegate_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
rm -rf delegate${delegate_version}

popd > /dev/null
