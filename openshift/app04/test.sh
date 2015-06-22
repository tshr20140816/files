#!/bin/bash

export TZ=JST-9

tail -n 10000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log

echo "$(date)"

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

rm -rf libxml2
rm -rf local
rm -rf local2

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

cd /tmp

rm -rf autossh

ruby_version=2.1.6

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
