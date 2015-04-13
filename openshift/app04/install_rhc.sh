#!/bin/bash

# rhc app create xxx ruby-2.0 --server openshift.redhat.com

# http://www.ibm.com/developerworks/jp/linux/library/l-distcc/index.html

set -x

export TZ=JST-9

# ***** distcc *****

distcc_version=3.1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2
tar jxf distcc-${distcc_version}.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
./configure --prefix=${OPENSHIFT_DATA_DIR}/distcc
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/distcc > /dev/null
touch ${OPENSHIFT_LOG_DIR}/distccd.log
./bin/distccd --daemon --listen ${OPENSHIFT_DIY_IP} --jobs 2 --port 33632 \
 --allow 0.0.0.0/0 --log-file=${OPENSHIFT_LOG_DIR}/distccd.log --verbose --log-stderr 
popd > /dev/null

# ***** openssh *****

openssh_version=6.8p1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/openssh-${openssh_version}.tar.gz
tar xfz openssh-${openssh_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/openssh-${openssh_version} > /dev/null
./configure --prefix=${OPENSHIFT_DATA_DIR}/openssh
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
export PATH="${OPENSHIFT_DATA_DIR}/openssh/bin:$PATH"
cat << __HEREDOC__ >> ${OPENSHIFT_DATA_DIR}/openssh/etc/ssh_config

IdentityFile ${OPENSHIFT_DATA_DIR}.ssh/id_rsa
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
LogLevel QUIET
__HEREDOC__
popd > /dev/null

# ***** rhc *****

gem install commander -v 4.2.1
gem install rhc

cat << '__HEREDOC__'
export TMOUT=0
export HOME=${OPENSHIFT_DATA_DIR}
export PATH="${OPENSHIFT_DATA_DIR}/openssh/bin:$PATH"
rhc setup --server openshift.redhat.com --create-token -l mail_address -p password
__HEREDOC__
