#!/bin/bash

# ruby-2.0

set -x

export TZ=JST-9

# ***** distcc *****

distcc_version=3.1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2
tar jxf distcc-${distcc_version}.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
# ./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/distcc \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc.log
mkdir ${OPENSHIFT_DATA_DIR}.distcc
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc

export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"

# ***** openssh *****

openssh_version=6.8p1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/openssh-${openssh_version}.tar.gz
tar xfz openssh-${openssh_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/openssh-${openssh_version} > /dev/null
# ./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/openssh \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

export PATH="${OPENSHIFT_DATA_DIR}/openssh/bin:$PATH"

cat << __HEREDOC__ >> ${OPENSHIFT_DATA_DIR}/openssh/etc/ssh_config

IdentityFile ${OPENSHIFT_DATA_DIR}.ssh/id_rsa
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
LogLevel QUIET
__HEREDOC__

cat << __HEREDOC__ > ${OPENSHIFT_DATA_DIR}/.ssh/config
Host *
ControlMaster auto
ControlPath /tmp/.ssh_tmp/master-%r@%h:%p
__HEREDOC__

# ***** Tcl *****

tcl_version=8.6.3

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://prdownloads.sourceforge.net/tcl/tcl${tcl_version}-src.tar.gz
tar xfz tcl${tcl_version}-src.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/tcl${tcl_version}/unix > /dev/null
./configure --help
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

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
# gem environment
gem install commander -v 4.2.1 --no-rdoc --no-ri
gem install rhc --no-rdoc --no-ri
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"

openshift_account=account
openshift_password=password
echo set timeout 60 > ${OPENSHIFT_TMP_DIR}/rhc_setup.txt
echo spawn ${OPENSHIFT_DATA_DIR}.gem/bin/rhc setup --server openshift.redhat.com \
 --create-token -l ${openshift_account} -p ${openshift_password} >> ${OPENSHIFT_TMP_DIR}/rhc_setup.txt

cat << '__HEREDOC__' >> ${OPENSHIFT_TMP_DIR}/rhc_setup.txt
expect "(yes|no)"
send "yes\r"
expect "(yes|no)"
send "yes\r"
expect "Provide a name for this key"
send "\r"
interact
__HEREDOC__

env_home_backup=${HOME}
export HOME=${OPENSHIFT_DATA_DIR}
${OPENSHIFT_DATA_DIR}/tcl/bin/expect -f ${OPENSHIFT_TMP_DIR}/rhc_setup.txt

# ssh -fMN xxxxx@xxxxx-xxxxx.rhcloud.com
# export DISTCC_HOSTS='xxxxx@xxxxx-xxxxx.rhcloud.com:/var/lib/openshift/xxxxx/app-root/data/distcc/bin/distccd'
export HOME=${env_home_backup}

# ***** bash_profile *****

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
touch .bash_profile
cat << '__HEREDOC__' >> .bash_profile

export TMOUT=0
export TZ=JST-9
alias ls='ls -lang --color=auto'
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:${OPENSHIFT_DATA_DIR}/openssh/bin:${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export env_home_backup=${HOME}
# export HOME=${OPENSHIFT_DATA_DIR}
export CC=distcc
export CXX=distcc
__HEREDOC__
popd > /dev/null

# ***** vim *****

echo set number >> ${OPENSHIFT_DATA_DIR}/.vimrc
