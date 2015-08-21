#!/bin/bash

apt-get update
apt-get upgrade
apt-get install telnetd sudo vim ntp

sed -i -e "s|#HandleLidSwitch=suspend|HandleLidSwitch=ignore|g" /etc/systemd/logind.conf

apt-get install distcc openssh-client rhc

cd ~/.ssh
mv config config.org
cat << __HEREDOC__ > config
Host *
  IdentityFile ~/.ssh/id_rsa
  StrictHostKeyChecking no
  BatchMode yes
  UserKnownHostsFile /dev/null
  LogLevel QUIET
  Protocol 2
  Ciphers arcfour256,arcfour128
  AddressFamily inet
  PreferredAuthentications publickey
  PasswordAuthentication no
  ConnectionAttempts 5
  ControlMaster auto
  ControlPath ~/.ssh/master-%r@%h:%p
  ControlPersist 30m
  ServerAliveInterval 60
__HEREDOC__

rhc setup --server openshift.redhat.com --create-token -l ${openshift_account} -p ${openshift_password}
# ★ アカウント分繰り返す
# ★ ~/distcc_hosts.txt を作る

rm -f /var/log/distcc.log
export DISTCC_LOG=/var/log/distcc.log
# export DISTCC_LOG=/dev/null
export DISTCC_DIR=~/.distcc
mkdir ${DISTCC_DIR}
tmp_string="$(cat ~/distcc_hosts.txt)"
export DISTCC_HOSTS="${tmp_string}"
export DISTCC_SSH="~/distcc-ssh"
cd ~
cat << '__HEREDOC__' > distcc-ssh
#!/bin/bash

# export TZ=JST-9
# export HOME=~
# echo "$(date +%Y/%m/%d" "%H:%M:%S) $@" >> var/log/distcc_ssh.log
exec ssh -F ~/.ssh/config $@
__HEREDOC__
chmod +x distcc-ssh

export CC="distcc gcc"
export CXX="distcc gcc"

# apt-get install gcc
time apt-get install build-essential fakeroot kernel-package libncurses5-dev
cd /usr/src
time apt-get source linux
time apt-get build-dep linux

ls -lang /boot/config*

# cp /boot/config-* ./.config
cp /boot/config-$(uname -r) ./.config
make menuconfig
# Pentium-4
# http://www.itmedia.co.jp/enterprise/articles/0708/21/news018_2.html
# http://d.hatena.ne.jp/cupnes/20110226/1298713968

export CONCURRENCY_LEVEL=3
# export CFLAGS="-march=native -O2"
export CFLAGS="-march=pentium4 -O2"
export CXXFLAGS="$CFLAGS"

make-kpkg clean
time make-kpkg --rootcmd fakeroot --initrd --revision=$(date '+%Y%m%d%H') kernel_image kernel_headers modules_image

cd ..
ls -la
# dpkg -i ...
