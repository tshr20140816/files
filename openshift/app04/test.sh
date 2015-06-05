#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log.*
rm -f ${OPENSHIFT_LOG_DIR}/ccache.log
rm -f cc*.s

ls -lang ${OPENSHIFT_DATA_DIR}/.distcc/lock

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
# export CC="ccache gcc"
# export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
# export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M

ccache -s
ccache -z

cd ${OPENSHIFT_DATA_DIR}/ccache/bin 
ln -s ccache cc
ln -s ccache gcc

rm -f ${OPENSHIFT_LOG_DIR}/ccache.log
mkdir ${OPENSHIFT_TMP_DIR}/ccache
mkdir ${OPENSHIFT_TMP_DIR}/tmp_ccache

cd /tmp

ls -lang

# [ -f ./binutils-2.25.tar.bz2 ] || wget http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.bz2
# rm -rf binutils-2.25
# tar jxf binutils-2.25.tar.bz2
# cd binutils-2.25
# ./configure --help
# ./configure --enable-gold=yes --disable-libquadmath --disable-libstdcxx > /dev/null
# time make -j4 > /dev/null

# ccache -s

find binutils-2.25 -name ld.* -print

# tree

cd ${OPENSHIFT_DATA_DIR}/ccache/bin 
unlink cc
unlink gcc

mkdir ${OPENSHIFT_DATA_DIR}/.ssh
mkdir ${OPENSHIFT_TMP_DIR}/.ssh
cat << __HEREDOC__ > ${OPENSHIFT_DATA_DIR}/.ssh/config
Host *
  IdentityFile __OPENSHIFT_DATA_DIR__.ssh/id_rsa
  StrictHostKeyChecking no
#  BatchMode yes
  UserKnownHostsFile /dev/null
  LogLevel QUIET
#  LogLevel DEBUG3
  Protocol 2
  Ciphers arcfour256,arcfour128
  AddressFamily inet
#  PreferredAuthentications publickey,gssapi-with-mic,hostbased,keyboard-interactive,password
  PreferredAuthentications publickey
  PasswordAuthentication no
  GSSAPIAuthentication no
  ConnectionAttempts 5
  ControlMaster auto
  # ControlPath too long
#  ControlPath __OPENSHIFT_DATA_DIR__.ssh/master-%r@%h:%p
  ControlPath __OPENSHIFT_TMP_DIR__.ssh/master-%r@%h:%p
  ControlPersist 30m
  ServerAliveInterval 60
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" ${OPENSHIFT_DATA_DIR}/.ssh/config
sed -i -e "s|__OPENSHIFT_TMP_DIR__|${OPENSHIFT_TMP_DIR}|g" ${OPENSHIFT_DATA_DIR}/.ssh/config

ssh -F ${OPENSHIFT_DATA_DIR}/.ssh/config 55630afc5973caf283000214@v1-20150216.rhcloud.com pwd 2>&1
ssh -O check -F ${OPENSHIFT_DATA_DIR}/.ssh/config 55630afc5973caf283000214@v1-20150216.rhcloud.com 2>&1
