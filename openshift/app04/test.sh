#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

cd /tmp

export HOME=$OPENSHIFT_DATA_DIR
cd .ssh
cat << '__HEREDOC__' > config
Host *
  IdentityFile __OPENSHIFT_DATA_DIR__.ssh/id_rsa
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel QUIET
#  LogLevel DEBUG3
  Protocol 2
  PasswordAuthentication no
  ConnectionAttempts 5
  ControlMaster auto
  ControlPath /tmp/.ssh/master-%r@%h:%p
  ControlPersist 2m
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" config

ssh -24n -F config 55630afc5973caf283000214@v1-20150216.rhcloud.com pwd
ssh -24n -F config 55630b63e0b8cd7ed000007f@v2-20150216.rhcloud.com pwd
ssh -24n -F config 55630c675973caf283000251@v3-20150216.rhcloud.com pwd

ps auwx | grep ssh
