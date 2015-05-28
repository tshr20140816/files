#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

whereis ld
whereis yacc
whereis byacc
whereis bison
ls -al /usr/bin/ld
#ld --version
#ld --help

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

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
  Ciphers arcfour
  PasswordAuthentication no
  ConnectionAttempts 5
  ControlMaster auto
  ControlPath /tmp/.ssh/master-%r@%h:%p
  ControlPersist 60m
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" config

ps auwx | grep ssh | grep -v grep

date

nohup ssh -24MNn -F /tmp/.ssh/config 555894314382ec8df40000e1@b1-20150430.rhcloud.com &
ssh -O check -F /tmp/.ssh/config 555894314382ec8df40000e1@b1-20150430.rhcloud.com
sleep 5s

date

ps auwx | grep ssh | grep -v grep

date

cd /tmp
rm -f binutils-2.25.tar.gz
rm -rf binutils-2.25
wget http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.gz > /dev/null
tar zxf binutils-2.25.tar.gz
cd binutils-2.25/gold
date
./configure --help
./configure --enable-gold=yes --enable-threads --enable-targets
make -j2
