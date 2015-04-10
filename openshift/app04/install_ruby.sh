#!/bin/bash

set -x

# export TZ=JST-9

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
popd > /dev/null

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem

# ***** rbenv *****

pushd ${OPENSHIFT_TMP_DIR}
wget https://raw.github.com/Seppone/openshift-rbenv-installer/master/bin/rbenv-installer
bash rbenv-installer
popd

export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"

rbenv -v

# ***** ruby *****

ruby_version=2.1.5

export CFLAGS="-O2 -march=native" 
export CXXFLAGS="-O2 -march=native" 
time CONFIGURE_OPTS="--disable-install-doc --mandir=/tmp/man --docdir=/tmp/doc" \
 MAKE_OPTS="-j$(grep -c -e processor /proc/cpuinfo)" \
 rbenv install -v ${ruby_version}

rbenv global ${ruby_version}
rbenv rehash

find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
 | xargs -0 perl -pi -e "s/0\.0\.0\.0/${OPENSHIFT_DIY_IP}/g"

# ***** rhc *****

time rbenv exec gem install rhc --no-rdoc --no-ri --verbose
rbenv rehash
env_home_backup=${HOME}
export HOME=${OPENSHIFT_DATA_DIR}
cat << '__HEREDOC__'
${OPENSHIFT_DATA_DIR}.gem/bin/rhc setup --server openshift.redhat.com --create-token -l mail_address -p password
__HEREDOC__
