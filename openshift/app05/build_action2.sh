#!/bin/bash

# distcc のサーバは3機従えておく

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
rm -f ${OPENSHIFT_LOG_DIR}/distcc.log

# makeターゲットのバージョン取得
while read LINE
do
    product=$(echo "${LINE}" | awk '{print $1}')
    version=$(echo "${LINE}" | awk '{print $2}')
    eval "${product}"="${version}"
done < ${OPENSHIFT_DATA_DIR}/version_list

# 環境変数

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/openssh/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/xz/bin:$PATH"

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
export CCACHE_PREFIX=distcc
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_MAXSIZE=300M
# ログ多すぎ
# export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_LOGFILE=/dev/null

rm -f ${OPENSHIFT_LOG_DIR}/distcc.log
export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc.log
# export DISTCC_LOG=/dev/null
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
tmp_string="$(cat ${OPENSHIFT_DATA_DIR}/distcc_hosts.txt)"
export DISTCC_HOSTS="${tmp_string}"
export DISTCC_SSH="${OPENSHIFT_DATA_DIR}/bin/distcc-ssh"

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem

export CFLAGS="-O2 -march=core2 -maes -mavx -mcx16 -mpclmul -mpopcnt -msahf"
export CFLAGS="${CFLAGS} -msse -msse2 -msse3 -msse4 -msse4.1 -msse4.2 -mssse3 -mtune=generic"
export CFLAGS="${CFLAGS} -pipe -fomit-frame-pointer -s"
# export CFLAGS="-O2 -march=core2 -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

export HOME=${OPENSHIFT_DATA_DIR}

ccache --show-stats
ccache --zero-stats
ccache --print-config

# ssh

pushd ${OPENSHIFT_DATA_DIR}/.ssh > /dev/null
cat << __HEREDOC__ > config
Host *
  IdentityFile __OPENSHIFT_DATA_DIR__.ssh/id_rsa
  StrictHostKeyChecking no
  BatchMode yes
  UserKnownHostsFile /dev/null
  LogLevel QUIET
#  LogLevel DEBUG3
  Protocol 2
  Ciphers arcfour256,arcfour128
  AddressFamily inet
  PreferredAuthentications publickey
  PasswordAuthentication no
  # Unsupported option "gssapiauthentication"
  ConnectionAttempts 5
  ControlMaster auto
  # ControlPath too long
#  ControlPath __OPENSHIFT_DATA_DIR__.ssh/master-%r@%h:%p
  ControlPath __OPENSHIFT_TMP_DIR__.ssh/master-%r@%h:%p
  ControlPersist 30m
  ServerAliveInterval 60
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" config
sed -i -e "s|__OPENSHIFT_TMP_DIR__|${OPENSHIFT_TMP_DIR}|g" config
popd > /dev/null
cat ${OPENSHIFT_DATA_DIR}/.ssh/config

# ssh 接続確認

ls -lang ${OPENSHIFT_DATA_DIR}/.distcc/lock
rm -f ${OPENSHIFT_DATA_DIR}/.distcc/lock/backoff_*
rm -f ${OPENSHIFT_DATA_DIR}/.distcc/lock/*
rm -f ${OPENSHIFT_TMP_DIR}/.ssh/*

ssh -V
${OPENSHIFT_DATA_DIR}/openssh/bin/ssh -V
if [ -f ${OPENSHIFT_DATA_DIR}/user_fqdn.txt ]; then
    for line in $(cat ${OPENSHIFT_DATA_DIR}/user_fqdn.txt)
    do
        user_fqdn=$(echo "${line}")
        ssh -O exit -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} 2>&1
        ssh -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} pwd 2>&1
        ssh -O check -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} 2>&1
    done
fi

# ***** apache *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) apache"

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

rm -rf httpd-${apache_version}
rm -f httpd-${apache_version}.tar.bz2

cp ${OPENSHIFT_DATA_DIR}/files/httpd-${apache_version}.tar.bz2 ./
[ -f httpd-${apache_version}.tar.bz2 ] || wget http://ftp.riken.jp/net/apache//httpd/httpd-${apache_version}.tar.bz2
tar jxf httpd-${apache_version}.tar.bz2
pushd httpd-${apache_version} > /dev/null
./configure --help
# --enable-mods-shared='all proxy ssl mem_cache file_cache disk_cache'
./configure \
 --prefix=${data_dir}/apache \
 --mandir=${tmp_dir}/man \
 --docdir=${tmp_dir}/doc \
 --disable-imagemap \
 --disable-status \
 --disable-userdir \
 --disable-include \
 --disable-authz-groupfile \
 --enable-mods-shared='all proxy'

# 3機がけ前提 1機あたり4プロセス
# time make -j$(grep -c -e processor /proc/cpuinfo)
time make -j12
popd > /dev/null

ccache --show-stats

rm -f ${app_uuid}_maked_httpd-${apache_version}.tar.bz2
# xz としたいが圧縮に時間が掛かってボトルネックとなるので bz2 とする
time tar jcf ${app_uuid}_maked_httpd-${apache_version}.tar.bz2 httpd-${apache_version}
mv -f ${app_uuid}_maked_httpd-${apache_version}.tar.bz2 ${OPENSHIFT_DATA_DIR}/files/
rm -rf httpd-${apache_version}
rm -f httpd-${apache_version}.tar.bz2

popd > /dev/null

ls -lang ${OPENSHIFT_DATA_DIR}/.distcc/lock

# ***** ruby (rbenv) *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) ruby"

rm -rf ${OPENSHIFT_DATA_DIR}.gem
rm -rf ${OPENSHIFT_DATA_DIR}.rbenv

if [ -f ${OPENSHIFT_DATA_DIR}/files/maked_ruby_${ruby_version}_rbenv.tar.xz ]; then
    pushd ${OPENSHIFT_DATA_DIR} > /dev/null
    cp -f ./files/maked_ruby_${ruby_version}_rbenv.tar.xz ./
    tar Jxf maked_ruby_${ruby_version}_rbenv.tar.xz
    rm -f maked_ruby_${ruby_version}_rbenv.tar.xz
    popd > /dev/null
else
    pushd ${OPENSHIFT_TMP_DIR} > /dev/null
    rm -f rbenv-installer
    wget https://raw.github.com/Seppone/openshift-rbenv-installer/master/bin/rbenv-installer
    bash rbenv-installer
    rm rbenv-installer
    popd > /dev/null

    export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
    eval "$(rbenv init -)"

    # https://github.com/sstephenson/ruby-build#special-environment-variables
    export RUBY_CFLAGS="${CFLAGS}"
    export CONFIGURE_OPTS="--disable-install-doc --mandir=${OPENSHIFT_TMP_DIR}/man --docdir=${OPENSHIFT_TMP_DIR}/doc --infodir=${OPENSHIFT_TMP_DIR}/info"
    # 3機がけ前提 1機あたり4プロセス
    # export MAKE_OPTS="-j $(grep -c -e processor /proc/cpuinfo)"
    export MAKE_OPTS="-j 12"
    time rbenv install -v ${ruby_version}
    unset RUBY_CFLAGS
    unset CONFIGURE_OPTS
    unset MAKE_OPTS

    # pushd ${OPENSHIFT_DATA_DIR}/.rbenv/versions/${ruby_version}/lib/ruby/2.1.0/x86_64-linux/ > /dev/null
    # time find ./ \
    #  -name "*.so" -type f -print0 \
    #  | xargs -0i file {} \
    #  | grep -e "not stripped" \
    #  | awk -F':' '{printf $1"\n"}' \
    #  | tee ${OPENSHIFT_TMP_DIR}/strip_starget.txt
    # wc -l ${OPENSHIFT_TMP_DIR}/strip_starget.txt
    # time cat ${OPENSHIFT_TMP_DIR}/strip_starget.txt | xargs -t -P 4 -n 30 strip --strip-all
    # rm -f ${OPENSHIFT_TMP_DIR}/strip_starget.txt
    # popd > /dev/null

    ccache --show-stats

    pushd ${OPENSHIFT_DATA_DIR}
    time tar Jcf maked_ruby_${ruby_version}_rbenv.tar.xz ./.rbenv
    mv maked_ruby_${ruby_version}_rbenv.tar.xz ./files/
    popd > /dev/null
fi

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
find ./.rbenv/ -name '*' -type f -print0 | xargs -0i -t -n 1 sed -i -e "s|${OPENSHIFT_DATA_DIR}|${data_dir}|g" {}

rm -f ${app_uuid}_maked_ruby_${ruby_version}_rbenv.tar.xz
time tar Jcf ${app_uuid}_maked_ruby_${ruby_version}_rbenv.tar.xz ./.rbenv
# time tar cf - ./.rbenv \
#  | ${OPENSHIFT_DATA_DIR}/xz/bin/xz -f --memlimit=256MiB \
#  > ${app_uuid}_maked_ruby_${ruby_version}_rbenv.tar.xz
mv -f ${app_uuid}_maked_ruby_${ruby_version}_rbenv.tar.xz ${OPENSHIFT_DATA_DIR}/files/
rm -rf ${OPENSHIFT_DATA_DIR}.rbenv

popd > /dev/null

ls -lang ${OPENSHIFT_DATA_DIR}/.distcc/lock

# ***** php *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) php"

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

unlink apache 2>/dev/null
ln -s ${OPENSHIFT_DATA_DIR}/apache/ apache

rm -rf php-${php_version}

if [ -f ${OPENSHIFT_DATA_DIR}/files/maked_php-${php_version}.tar.xz ]; then
    cp ${OPENSHIFT_DATA_DIR}/files/maked_php-${php_version}.tar.xz ./
    tar Jxf maked_php-${php_version}.tar.xz
    rm maked_php-${php_version}.tar.xz
else
    rm -f php-${php_version}.tar.xz

    cp ${OPENSHIFT_DATA_DIR}/files/php-${php_version}.tar.xz ./
    if [ ! -f php-${php_version}.tar.xz ]; then
        wget http://jp2.php.net/get/php-${php_version}.tar.xz/from/this/mirror -O php-${php_version}.tar.xz
    fi
    tar Jxf php-${php_version}.tar.xz
    pushd php-${php_version} > /dev/null
    ./configure -help
    ./configure \
     --prefix=${OPENSHIFT_DATA_DIR}/php \
     --mandir=${tmp_dir}/man \
     --docdir=${tmp_dir}/doc \
     --infodir=${tmp_dir}/info \
     --with-apxs2=${OPENSHIFT_TMP_DIR}/apache/bin/apxs \
     --with-mysql \
     --with-pdo-mysql \
     --without-sqlite3 \
     --without-pdo-sqlite \
     --without-cdb \
     --without-pear \
     --with-curl \
     --with-libdir=lib64 \
     --with-bz2 \
     --with-iconv \
     --with-openssl \
     --with-zlib \
     --with-gd \
     --enable-exif \
     --enable-ftp \
     --enable-xml \
     --enable-mbstring \
     --enable-mbregex \
     --enable-sockets \
     --disable-ipv6 \
     --disable-debug \
     --with-gettext=${OPENSHIFT_DATA_DIR}/php \
     --with-zend-vm=GOTO

    # time make -j12
    time make
    ccache --show-stats
    popd > /dev/null
    tar Jcf maked_php-${php_version}.tar.xz php-${php_version}
    mv maked_php-${php_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/

    rm -f php-${php_version}.tar.xz
fi

find ./php-${php_version} -name '*' -type f -print0 | xargs -0i -t -n 1 sed -i -e "s|${OPENSHIFT_DATA_DIR}|${data_dir}|g" {}

rm -f ${app_uuid}_maked_php-${php_version}.tar.xz
time tar Jcf ${app_uuid}_maked_php-${php_version}.tar.xz php-${php_version}
mv -f ${app_uuid}_maked_php-${php_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
rm -rf php-${php_version}

unlink apache

popd > /dev/null

ls -lang ${OPENSHIFT_DATA_DIR}/.distcc/lock

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
 --disable-sasl \
 --enable-jobserver=12

# cat config.log

# 3機がけ前提 1機あたり2プロセス
# time make -j$(grep -c -e processor /proc/cpuinfo)
# time make -j6
time make
popd > /dev/null
ccache --show-stats
rm -f ${app_uuid}_maked_libmemcached-${libmemcached_version}.tar.xz
time tar Jcf ${app_uuid}_maked_libmemcached-${libmemcached_version}.tar.xz libmemcached-${libmemcached_version}
# time tar cf - libmemcached-${libmemcached_version} \
#  | ${OPENSHIFT_DATA_DIR}/xz/bin/xz -f --memlimit=256MiB \
#  > ${app_uuid}_maked_libmemcached-${libmemcached_version}.tar.xz
mv -f ${app_uuid}_maked_libmemcached-${libmemcached_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
rm -rf libmemcached-${libmemcached_version}
rm -f libmemcached-${libmemcached_version}.tar.gz

popd > /dev/null

wait

ls -lang ${OPENSHIFT_DATA_DIR}/.distcc/lock

# ***** cadaver *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver"

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

rm -f cadaver-${cadaver_version}.tar.gz
rm -rf cadaver-${cadaver_version}

cp ${OPENSHIFT_DATA_DIR}/files/cadaver-${cadaver_version}.tar.gz ./

tar zxf cadaver-${cadaver_version}.tar.gz

pushd ${OPENSHIFT_TMP_DIR}/cadaver-${cadaver_version} > /dev/null
./configure --help
./configure \
 --mandir=${tmp_dir}/man \
 --docdir=${tmp_dir}/doc \
 --with-ssl=openssl \
 --prefix=${data_dir}/cadaver

time make -j6
popd > /dev/null
ccache --show-stats
rm -f ${app_uuid}_maked_cadaver-${cadaver_version}.tar.xz
time tar Jcf ${app_uuid}_maked_cadaver-${cadaver_version}.tar.xz cadaver-${cadaver_version}
# time tar cf - cadaver-${cadaver_version} \
#  | ${OPENSHIFT_DATA_DIR}/xz/bin/xz -f --memlimit=256MiB \
#  > ${app_uuid}_maked_cadaver-${cadaver_version}.tar.xz
mv -f ${app_uuid}_maked_cadaver-${cadaver_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
rm -rf cadaver-${cadaver_version}
rm -f cadaver-${cadaver_version}.tar.gz
popd > /dev/null

ls -lang ${OPENSHIFT_DATA_DIR}/.distcc/lock

# ***** delegate *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) delegate"

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

rm -rf delegate${delegate_version}
rm -f delegate${delegate_version}.tar.gz

if [ -f ${OPENSHIFT_DATA_DIR}/files/maked_delegate${delegate_version}.tar.xz ]; then
    pushd ${OPENSHIFT_DATA_DIR}/files > /dev/null
    cp -f maked_delegate${delegate_version}.tar.xz ${app_uuid}_maked_delegate${delegate_version}.tar.xz
    popd > /dev/null
else
    cp ${OPENSHIFT_DATA_DIR}/files/delegate${delegate_version}.tar.gz ./
    if [ ! -f delegate${delegate_version}.tar.gz ]; then
        wget http://www.delegate.org/anonftp/DeleGate/delegate${delegate_version}.tar.gz
    fi
    tar zxf delegate${delegate_version}.tar.gz

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
    ccache --show-stats
    pushd ${OPENSHIFT_DATA_DIR}/ccache/bin > /dev/null
    unlink cc
    unlink gcc
    popd > /dev/null
    export CC="ccache gcc"
    export CXX="ccache g++"

    rm -f ${app_uuid}_maked_delegate${delegate_version}.tar.xz
    time tar Jcf ${app_uuid}_maked_delegate${delegate_version}.tar.xz delegate${delegate_version}
    # time tar cf - delegate${delegate_version} \
    #  | ${OPENSHIFT_DATA_DIR}/xz/bin/xz -f --memlimit=256MiB \
    #  > ${app_uuid}_maked_delegate${delegate_version}.tar.xz
    cp -f ${app_uuid}_maked_delegate${delegate_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/maked_delegate${delegate_version}.tar.xz
    mv -f ${app_uuid}_maked_delegate${delegate_version}.tar.xz ${OPENSHIFT_DATA_DIR}/files/
    rm -rf delegate${delegate_version}
    rm -f delegate${delegate_version}.tar.gz
fi
popd > /dev/null

ls -lang ${OPENSHIFT_DATA_DIR}/.distcc/lock

for line in $(cat ${OPENSHIFT_DATA_DIR}/user_fqdn.txt)
do
    user_fqdn=$(echo "${line}")
    ssh -O exit -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} 2>&1
done

wait

rm -f ${OPENSHIFT_TMP_DIR}/build_now

quota -s > ${OPENSHIFT_LOG_DIR}/quota.txt

echo "$(date +%Y/%m/%d" "%H:%M:%S) finish"
