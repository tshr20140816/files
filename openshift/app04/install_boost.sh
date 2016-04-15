#!/bin/bash

export TZ=JST-9
set -x

quota -s
oo-cgroup-read memory.usage_in_bytes
oo-cgroup-read memory.failcnt

cd /tmp
wget https://distcc.googlecode.com/files/distcc-3.1.tar.bz2
tar jxf distcc-3.1.tar.bz2
rm -f distcc-3.1.tar.bz2
cd distcc-3.1
./configure --prefix=${OPENSHIFT_DATA_DIR}/distcc \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man
time make -j4
make install

mkdir ${OPENSHIFT_DATA_DIR}/.ssh
mkdir ${OPENSHIFT_TMP_DIR}/.ssh
cd ${OPENSHIFT_DATA_DIR}/.ssh
ssh-keygen -t rsa -f id_rsa -P ''
chmod 600 id_rsa
chmod 600 id_rsa.pub

cat << '__HEREDOC__' > config
Host *
  IdentityFile __OPENSHIFT_DATA_DIR__.ssh/id_rsa
  StrictHostKeyChecking no
  BatchMode yes
  UserKnownHostsFile /dev/null
  LogLevel QUIET
  Protocol 2
  Ciphers arcfour256,arcfour128
  # Ciphers none
  AddressFamily inet
  PreferredAuthentications publickey
  PasswordAuthentication no
  GSSAPIAuthentication no
  ConnectionAttempts 5
  ControlMaster auto
  ControlPath __OPENSHIFT_TMP_DIR__.ssh/master-%r@%h:%p
  ControlPersist yes
  ServerAliveInterval 60
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" config
sed -i -e "s|__OPENSHIFT_TMP_DIR__|${OPENSHIFT_TMP_DIR}|g" config

cd ${OPENSHIFT_DATA_DIR}/distcc/bin > /dev/null
cat << '__HEREDOC__' > distcc-ssh
#!/bin/bash

export HOME=${OPENSHIFT_DATA_DIR}
exec /usr/bin/ssh -F ${OPENSHIFT_DATA_DIR}/.ssh/config "$@"
__HEREDOC__
chmod +x distcc-ssh

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
export HOME=${OPENSHIFT_DATA_DIR}
# gem --version
# gem environment
# gem help install

gem install rhc --no-rdoc --no-ri -- --with-cflags=\"-O2 -pipe -march=native -fomit-frame-pointer -s\"

# yes | rhc setup --server openshift.redhat.com --create-token -l ${distcc_server_account} -p ${distcc_server_password}
# rhc apps | grep -e SSH | grep -v -e ${OPENSHIFT_APP_UUID} | awk '{print $2}' | tee -a ${OPENSHIFT_DATA_DIR}/params/user_fqdn.txt

# ssh -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} pwd
# ssh -t -t -O check -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn}
# distcc_hosts_string="${user_fqdn}/4:/var/lib/openshift/${user_string}/app-root/data/distcc/bin/distccd_start "

export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc.log
