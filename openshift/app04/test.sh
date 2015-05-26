#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

cd /tmp

# export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
# export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
export HOME=${OPENSHIFT_DATA_DIR}

# rhc apps

cd $OPENSHIFT_DATA_DIR
cd .ssh

cat << '__HEREDOC__' > config
Host *
  IdentityFile __OPENSHIFT_DATA_DIR__.ssh/id_rsa
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
#  LogLevel QUIET
  LogLevel DEBUG3
  Protocol 2
  PasswordAuthentication no
  ConnectionAttempts 5
  ControlMaster auto
  # ControlPath too long
  # ControlPath __OPENSHIFT_DATA_DIR__.ssh/master-%r@%h:%p
  ControlPath /tmp/master-%r@%h:%p
# ssh -O exit REMOTE
#  ControlPersist yes
  ControlPersist 60s
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" config

ssh -24n -F config 55630afc5973caf283000214@v1-20150216.rhcloud.com pwd

ps auwx | grep ssh
