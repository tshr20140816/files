#!/bin/bash

export TZ=JST-9

tail -n 10000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log.*
rm -f ${OPENSHIFT_LOG_DIR}/ccache.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
rm -f ${OPENSHIFT_TMP_DIR}/distcc_server_stderr_*
ls -d /tmp/cc* | grep -v ccache$ | xargs rm -f

set -x

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

cd /tmp

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

export LD=ld.gold
mkdir -p /tmp/local/bin
cp /tmp/ld.gold /tmp/local/bin/
export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export PATH="/tmp/local/bin:$PATH"

cd ${OPENSHIFT_DATA_DIR}/ccache/bin 
unlink cc
unlink gcc

export CC="ccache gcc"
export CXX="ccache g++"

export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
rm -rf ${OPENSHIFT_TMP_DIR}/tmp_ccache
mkdir ${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M
export CCACHE_NLEVELS=3

cd /tmp

rm -rf ${OPENSHIFT_DATA_DIR}/.rbenv
rm -rf ${OPENSHIFT_DATA_DIR}/.gem

ruby_version=2.1.6

export HOME=${OPENSHIFT_DATA_DIR}
export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem

[ -f rbenv-installer ] || wget https://raw.github.com/Seppone/openshift-rbenv-installer/master/bin/rbenv-installer
bash rbenv-installer

export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"

time \
 CONFIGURE_OPTS="--disable-install-doc --mandir=${OPENSHIFT_TMP_DIR}/man --docdir=${OPENSHIFT_TMP_DIR}/doc" \
 RUBY_CONFIGURE_OPTS="--with-out-ext=tk,tk/*" \
 MAKE_OPTS="-j $(grep -c -e processor /proc/cpuinfo)" \
 rbenv install -v ${ruby_version}

rbenv global ${ruby_version}
rbenv rehash
ruby -v

echo ${OPENSHIFT_PHP_IP}
# find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
#  | xargs -0i cp -f {} ${OPENSHIFT_TMP_DIR}
find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
 | xargs -0 perl -pi -e "s/0\.0\.0\.0/${OPENSHIFT_PHP_IP}/g"

# for gem in bundler rack passenger
# do
#     time rbenv exec gem install ${gem} --no-rdoc --no-ri --debug
#     rbenv rehash
# done

rbenv exec gem list
