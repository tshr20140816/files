#!/bin/bash

set -x

export TZ=JST-9

# ***** distcc *****

distcc_version=3.1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2
tar jxf distcc-${distcc_version}.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
./configure --prefix=${OPENSHIFT_DATA_DIR}/distcc --mandir=/tmp/man
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

# pushd ${OPENSHIFT_DATA_DIR}/distcc > /dev/null
# touch ${OPENSHIFT_LOG_DIR}/distccd.log
# ./bin/distccd --daemon --listen ${OPENSHIFT_DIY_IP} --jobs 2 --port 33632 \
#  --allow 0.0.0.0/0 --log-file=${OPENSHIFT_LOG_DIR}/distccd.log --verbose --log-stderr 
# popd > /dev/null
# lsof

# ***** openssh *****

openssh_version=6.8p1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/openssh-${openssh_version}.tar.gz
tar xfz openssh-${openssh_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/openssh-${openssh_version} > /dev/null
./configure --prefix=${OPENSHIFT_DATA_DIR}/openssh --mandir=/tmp/man
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

# export PATH="${OPENSHIFT_DATA_DIR}/openssh/bin:$PATH"
# env_home_backup=${HOME}
# export HOME=${OPENSHIFT_DATA_DIR}
# cd ${HOME}
# ssh-keygen -t rsa -N hogehoge
# ls -lang ${OPENSHIFT_DATA_DIR}/.ssh/
# ssh-keygen -i -f id_rsa.pub >> authorized_keys
# ssh -vvv ...
# export HOME=${HOME}

# ***** Tcl *****

tcl_version=8.6.3

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://prdownloads.sourceforge.net/tcl/tcl${tcl_version}-src.tar.gz
tar xfz tcl${tcl_version}-src.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/tcl${tcl_version}/unix > /dev/null
./configure \
     --mandir=${OPENSHIFT_TMP_DIR}/man \
     --disable-symbols \
     --prefix=${OPENSHIFT_DATA_DIR}/tcl
time make -j2 -l3
make install
popd > /dev/null

# ***** Expect *****

expect_version=5.45

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://downloads.sourceforge.net/project/expect/Expect/${expect_version}/expect${expect_version}.tar.gz
tar xfz expect${expect_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/expect${expect_version} > /dev/null
./configure \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --prefix=${OPENSHIFT_DATA_DIR}/expect
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

# ***** rhc *****

time gem install rhc --no-rdoc --no-ri --verbose
