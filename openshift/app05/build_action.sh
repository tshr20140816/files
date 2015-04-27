#!/bin/bash

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

memory_fail_count=$(oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}')
echo "$(date +%Y/%m/%d" "%H:%M:%S) Memory Fail Count : ${memory_fail_count}"

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

time make -j$(grep -c -e processor /proc/cpuinfo)
popd > /dev/null
ccache -s
rm -f ${app_uuid}_maked_httpd-${apache_version}.tar.bz2
time tar jcf ${app_uuid}_maked_httpd-${apache_version}.tar.bz2 httpd-${apache_version}
mv -f ${app_uuid}_maked_httpd-${apache_version}.tar.bz2 ${OPENSHIFT_DATA_DIR}/files/
rm -f ${app_uuid}_maked_httpd-${apache_version}.tar.xz
time tar Jcf ${app_uuid}_maked_httpd-${apache_version}.tar.xz httpd-${apache_version}
mv -f ${app_uuid}_maked_httpd-${apache_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
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

time make -j$(grep -c -e processor /proc/cpuinfo)
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

time \
 CONFIGURE_OPTS="--disable-install-doc --mandir=${OPENSHIFT_TMP_DIR}/man --docdir=${OPENSHIFT_TMP_DIR}/doc" \
 RUBY_CONFIGURE_OPTS="--with-out-ext=tk,tk/*" \
 MAKE_OPTS="-j $(grep -c -e processor /proc/cpuinfo)" \
 rbenv install -v ${ruby_version}

ccache -s

unset RBENV_ROOT
unset GEM_HOME
export PATH="${path_old}"

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
find ./.rbenv/ -name * -type f print0 | xargs sed -i -e "s|${OPENSHIFT_DATA_DIR}|${data_dir}|g"
rm -f ${app_uuid}_maked_ruby_${ruby_version}_rbenv.tar.xz
time tar Jcf ${app_uuid}_maked_ruby_${ruby_version}_rbenv.tar.xz ./.rbenv
mv -f ${app_uuid}_maked_ruby_${ruby_version}_rbenv.tar.xz ${OPENSHIFT_DATA_DIR}/files/
popd > /dev/null

rm -rf ${OPENSHIFT_DATA_DIR}.rbenv

# ***** tcl *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) tcl"

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

rm -rf delegate${delegate_version}
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

time make -j2 -l3
popd > /dev/null
ccache -s
rm -f ${app_uuid}_maked_tcl${tcl_version}-src.tar.xz
time tar Jcf ${app_uuid}_maked_tcl${tcl_version}-src.tar.xz tcl${tcl_version}
mv -f ${app_uuid}_maked_tcl${tcl_version}-src.tar.xz ${OPENSHIFT_DATA_DIR}/files/
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

echo "$(date +%Y/%m/%d" "%H:%M:%S) finish"
