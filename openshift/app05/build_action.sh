#!/bin/bash

if [ $# -ne 3 ]; then
    exit
fi

export host_name=${1}
export data_dir=${2}
export tmp_dir=${3}

if [ ! -f ${OPENSHIFT_DATA_DIR}/version_list ]; then
    exit
fi

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
rm -rf maked_httpd-${apache_version}.tar.xz
time tar Jcf ${host_name}_maked_httpd-${apache_version}.tar.xz httpd-${apache_version}
mv -f ${host_name}_maked_httpd-${apache_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
rm -rf httpd-${apache_version}

popd > /dev/null
