#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log.*
rm -f ${OPENSHIFT_LOG_DIR}/ccache.log
rm -f ${OPENSHIFT_TMP_DIR}/cc*.s

ls -lang ${OPENSHIFT_DATA_DIR}/.distcc/lock

cd /tmp

mkdir ${OPENSHIFT_DATA_DIR}/.ssh
mkdir ${OPENSHIFT_TMP_DIR}/.ssh
cat << __HEREDOC__ > ${OPENSHIFT_DATA_DIR}/.ssh/config
Host *
  IdentityFile __OPENSHIFT_DATA_DIR__.ssh/id_rsa
  StrictHostKeyChecking no
  BatchMode yes
  UserKnownHostsFile /dev/null
  LogLevel QUIET
#  LogLevel DEBUG3
  Protocol 2
  Ciphers arcfour256,arcfour128
  AddressFamily inet
#  PreferredAuthentications publickey,gssapi-with-mic,hostbased,keyboard-interactive,password
  PreferredAuthentications publickey
  PasswordAuthentication no
  GSSAPIAuthentication no
  ConnectionAttempts 5
  ControlMaster auto
  # ControlPath too long
#  ControlPath __OPENSHIFT_DATA_DIR__.ssh/master-%r@%h:%p
  ControlPath __OPENSHIFT_TMP_DIR__.ssh/master-%r@%h:%p
  ControlPersist 30m
  ServerAliveInterval 60
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" ${OPENSHIFT_DATA_DIR}/.ssh/config
sed -i -e "s|__OPENSHIFT_TMP_DIR__|${OPENSHIFT_TMP_DIR}|g" ${OPENSHIFT_DATA_DIR}/.ssh/config

mkdir ${OPENSHIFT_DATA_DIR}/bin
pushd ${OPENSHIFT_DATA_DIR}/bin > /dev/null
cat << '__HEREDOC__' > distcc-ssh
#!/bin/bash

export TZ=JST-9
export HOME=${OPENSHIFT_DATA_DIR}
echo "$(date +%Y/%m/%d" "%H:%M:%S) $@" >> ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
exec ssh -F ${OPENSHIFT_DATA_DIR}/.ssh/config $@
__HEREDOC__
chmod +x distcc-ssh
popd > /dev/null

export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"

cd ${OPENSHIFT_DATA_DIR}/distcc/bin 
ln -s distcc cc
ln -s distcc gcc

distcc_hosts_string="55630afc5973caf283000214@v1-20150216.rhcloud.com/4:/var/lib/openshift/55630afc5973caf283000214/app-root/data/distcc/bin/distccd_start"
distcc_hosts_string="${distcc_hosts_string} 55630b63e0b8cd7ed000007f@v2-20150216.rhcloud.com/4:/var/lib/openshift/55630b63e0b8cd7ed000007f/app-root/data/distcc/bin/distccd_start"
distcc_hosts_string="${distcc_hosts_string} 55630c675973caf283000251@v3-20150216.rhcloud.com/4:/var/lib/openshift/55630c675973caf283000251/app-root/data/distcc/bin/distccd_start"
export DISTCC_HOSTS="${distcc_hosts_string}"

# export DISTCC_LOG=/dev/null
export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc.log
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
mkdir ${OPENSHIFT_DATA_DIR}.distcc 2>/dev/null
export DISTCC_SSH="${OPENSHIFT_DATA_DIR}/bin/distcc-ssh"

export HOME=${OPENSHIFT_DATA_DIR}

cd /tmp

[ -f ./binutils-2.25.tar.bz2 ] || wget http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.bz2
rm -rf binutils-2.25
tar jxf binutils-2.25.tar.bz2
cd binutils-2.25
#./configure --help
./configure --enable-gold=yes --disable-libquadmath --disable-libstdcxx > /dev/null
time make -j12 > /dev/null

ls -lang

cd ${OPENSHIFT_DATA_DIR}/distcc/bin 
unlink cc
unlink gcc
