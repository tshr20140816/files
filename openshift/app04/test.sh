#!/bin/bash

# 1508

export TZ=JST-9

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

set -x

find / -name apxs -print 2>/dev/null

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

cflag_data=$(gcc -march=native -E -v - </dev/null 2>&1 | sed -n 's/.* -v - //p')
export CFLAGS="-O2 ${cflag_data} -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

cd /tmp
rm -f libmemcached-${libmemcached_version}.tar.gz
rm -rf libmemcached-${libmemcached_version}
openssh_version=6.6p1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/openssh-${openssh_version}.tar.gz
wget http://downloads.sourceforge.net/project/hpnssh/HPN-SSH%2014.5%206.6p1/openssh-6.6p1-hpnssh14v5.diff.gz
tar zxf openssh-${openssh_version}.tar.gz
gzip -d openssh-6.6p1-hpnssh14v5.diff.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/openssh-${openssh_version} > /dev/null
patch -p1 < ../openssh-6.6p1-hpnssh14v5.diff
./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/openssh \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --disable-etc-default-login \
 --disable-utmp \
 --disable-utmpx \
 --disable-wtmp \
 --disable-wtmpx \
 --with-lastlog=${OPENSHIFT_LOG_DIR}/ssh_lastlog.log
time make -j$(grep -c -e processor /proc/cpuinfo)

popd > /dev/null
