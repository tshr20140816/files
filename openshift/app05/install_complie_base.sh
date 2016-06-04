#!/bin/bash

distcc_server_account=""
distcc_server_password=""

set -x
export TZ=JST-9

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

# ***** openssh *****

openssh_version=6.9

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -q http://mirrors.sonic.net/pub/OpenBSD/OpenSSH/portable/openssh-${openssh_version}p1.tar.gz
tar xf openssh-${openssh_version}p1.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/openssh-${openssh_version}p1 > /dev/null
wget -q http://superb-sea2.dl.sourceforge.net/project/hpnssh/HPN-SSH%2014v7%206.9p1/openssh-6_9_P1-hpn-14.7.diff
patch < openssh-6_9_P1-hpn-14.7.diff
./configure --prefix=${OPENSHIFT_DATA_DIR}/ssh \
 --mandir=${OPENSHIFT_TMP_DIR}/gomi \
 --infodir=${OPENSHIFT_TMP_DIR}/gomi \
 --docdir=${OPENSHIFT_TMP_DIR}/gomi \
 --disable-largefile \
 --disable-etc-default-login \
 --disable-utmp \
 --disable-utmpx \
 --disable-wtmp \
 --disable-wtmpx \
 --without-ssh1 \
 --with-lastlog=${OPENSHIFT_LOG_DIR}/ssh_lastlog.log
time make -j4
make install
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -rf openssh-${openssh_version}p1 gomi
popd > /dev/null

mkdir ${OPENSHIFT_DATA_DIR}/.ssh
mkdir ${OPENSHIFT_TMP_DIR}/.ssh
pushd ${OPENSHIFT_DATA_DIR}/.ssh > /dev/null
ssh-keygen -t rsa -f id_rsa -P ''
chmod 600 id_rsa
chmod 600 id_rsa.pub
cat << '__HEREDOC__' > config
Host *
  IdentityFile __OPENSHIFT_DATA_DIR__.ssh/id_rsa
  StrictHostKeyChecking no
  BatchMode yes
  UserKnownHostsFile /dev/null
#  LogLevel INFO
#  LogLevel DEBUG3
  LogLevel QUIET
  Protocol 2
#  Ciphers arcfour256,arcfour128
  Ciphers arcfour256,arcfour128
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
popd > /dev/null

# ***** rhc *****

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
[ $(echo $PATH | grep -c ${OPENSHIFT_DATA_DIR}/.gem/bin) -eq 0 ] && export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
export HOME=${OPENSHIFT_DATA_DIR}

rm -f ${OPENSHIFT_DATA_DIR}/user_fqdn.txt

time gem install rhc --verbose --no-rdoc --no-ri --no-test -- --with-cflags=\"-O2 -pipe -march=native -fomit-frame-pointer -s\"
yes | rhc setup --server openshift.redhat.com --create-token -l ${distcc_server_account} -p ${distcc_server_password}
rhc apps | grep -e SSH | grep -v -e ${OPENSHIFT_APP_UUID} | awk '{print $2}' | tee -a ${OPENSHIFT_DATA_DIR}/user_fqdn.txt

rm -f  ${OPENSHIFT_DATA_DIR}/distcc_hosts.txt
for line in $(cat ${OPENSHIFT_DATA_DIR}/user_fqdn.txt)
do
    user_fqdn="${line}"
    ssh -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} pwd
    ssh -t -t -O check -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn}
    user_string=$(echo "${user_fqdn}" | awk -F@ '{print $1}')
    distcc_hosts_string="${user_fqdn}/4:/var/lib/openshift/${user_string}/app-root/data/distcc/bin/distccd_start "
    echo -n "${distcc_hosts_string}" >> ${OPENSHIFT_DATA_DIR}/distcc_hosts.txt
done

# ***** distcc *****

distcc_version=3.1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -q https://github.com/distcc/distcc/archive/distcc-${distcc_version}.tar.gz
tar xf distcc-${distcc_version}.tar.bz2
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/distcc \
 --mandir=${OPENSHIFT_TMP_DIR}/gomi \
 --without-avahi
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -rf distcc-${distcc_version} gomi
rm -f distcc-${distcc_version}.tar.gz
popd > /dev/null

mkdir ${OPENSHIFT_DATA_DIR}/.distcc

[ $(echo $PATH | grep -c ${OPENSHIFT_DATA_DIR}/distcc/bin) -eq 0 ] && export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
# export DISTCC_LOG=/dev/null
export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc.log
export DISTCC_SSH="${OPENSHIFT_DATA_DIR}/distcc/bin/distcc-ssh"

cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/distcc/bin/distcc-ssh
#!/bin/bash

export TZ=JST-9
export HOME=${OPENSHIFT_DATA_DIR}
echo "$(date +%Y/%m/%d" "%H:%M:%S) $*" >> ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
exec ${OPENSHIFT_DATA_DIR}/ssh/bin/ssh -F ${OPENSHIFT_DATA_DIR}/.ssh/config "$@"
__HEREDOC__
chmod +x ${OPENSHIFT_DATA_DIR}/distcc/bin/distcc-ssh

# ***** distcc hosts *****

export DISTCC_HOSTS="$(cat ${OPENSHIFT_DATA_DIR}/distcc_hosts.txt)"
export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"
export CC="distcc gcc"
export CXX="distcc g++"

cat << '__HEREDOC__' >> ${OPENSHIFT_DATA_DIR}/.bash_profile

export TMOUT=0
export TZ=JST-9
alias ls='ls -lang --color=auto'
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"
export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export HOME=${OPENSHIFT_DATA_DIR}
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc.log
export DISTCC_SSH="${OPENSHIFT_DATA_DIR}/distcc/bin/distcc-ssh"
export DISTCC_HOSTS="$(cat ${OPENSHIFT_DATA_DIR}/distcc_hosts.txt)"
export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"
export CC="distcc gcc"
export CXX="distcc g++"
__HEREDOC__

printenv | sort
