#!/bin/bash

# rhc app create xxx ruby-2.0 --server openshift.redhat.com

set -x

export TZ=JST-9

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
rhc setup --server openshift.redhat.com --create-token -l mail_address -p password
__HEREDOC__
