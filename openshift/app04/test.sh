#!/bin/bash

echo "1524"

set -x

quota -s
oo-cgroup-read memory.failcnt
echo "$(oo-cgroup-read memory.usage_in_bytes)" | awk '{printf "%\047d\n", $0}'

# oo-cgroup-read all
# oo-cgroup-read report

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

/usr/bin/gear start --trace

cd /tmp
ls -lang
cd $OPENSHIFT_DATA_DIR
ls -lang

quota -s

# -----

cd /tmp
rm -f test.php
# wget -q https://github.com/tshr20140816/files/raw/master/openshift/app04/test.php
# cp test.php $OPENSHIFT_REPO_DIR/test.php

rm -rf 20160506
rm -rf 20160509
# rm -rf gomi build
# rm -rf ${OPENSHIFT_DATA_DIR}/usr

# -----

cd /tmp

# mv d1.txt d3.txt
# mv d2.txt d4.txt
ls -lang

rm -f d3.txt d4.txt

ls -lang ${OPENSHIFT_REPO_DIR}

cd /tmp

ssh-keygen -t rsa -f id_rsa -P ''
chmod 600 id_rsa
chmod 600 id_rsa.pub

echo 'hoge' | openssl rsautl -encrypt -inkey ./id_rsa > pass.rsa
openssl rsautl -decrypt -inkey ./id_rsa -in pass.rsa

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
export HOME=${OPENSHIFT_DATA_DIR}

mkdir /tmp/.ssh

cd ${OPENSHIFT_DATA_DIR}/.ssh

cat << '__HEREDOC__' > config
Host *
  IdentityFile __OPENSHIFT_DATA_DIR__.ssh/id_rsa
  StrictHostKeyChecking no
  BatchMode yes
  UserKnownHostsFile /dev/null
  LogLevel QUIET
#  LogLevel DEBUG3
  Protocol 2
#  Ciphers arcfour256,arcfour128
  Ciphers arcfour,blowfish-cbc
  Macs hmac-md5-96
  Compression no
  AddressFamily inet
  PreferredAuthentications publickey
  PasswordAuthentication no
  GSSAPIAuthentication no
  ConnectionAttempts 5
  ControlMaster auto
  # ControlPath too long
#  ControlPath __OPENSHIFT_DATA_DIR__.ssh/master-%r@%h:%p
  ControlPath __OPENSHIFT_TMP_DIR__.ssh/master-%r@%h:%p
  ControlPersist yes
  ServerAliveInterval 60
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" config
sed -i -e "s|__OPENSHIFT_TMP_DIR__|${OPENSHIFT_TMP_DIR}|g" config

cat config

ssh -F ${OPENSHIFT_DATA_DIR}/.ssh/config 56f9bba87628e1611400013c@b10-20160312.rhcloud.com pwd
tree -a /tmp/.ssh
ssh -t -t -O exit -F ${OPENSHIFT_DATA_DIR}/.ssh/config 56f9bba87628e1611400013c@b10-20160312.rhcloud.com
tree -a /tmp/.ssh

quota -s
echo "FINISH"
exit
