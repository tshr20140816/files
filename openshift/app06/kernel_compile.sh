#!/bin/bash

set -x

apt-get update
apt-get upgrade
apt-get install telnetd sudo vim ntp

sed -i -e "s|#HandleLidSwitch=suspend|HandleLidSwitch=ignore|g" /etc/systemd/logind.conf

apt-get install distcc openssh-client rhc

rhc setup --server openshift.redhat.com --create-token -l ${openshift_account} -p ${openshift_password}

# apt-get install gcc
time apt-get install build-essential fakeroot kernel-package libncurses5-dev
cd /usr/src
time apt-get source linux
time apt-get build-dep linux

ls -lang /boot/config*

exit
# cp /boot/config-* ./.config
cp /boot/config-$(uname -r) ./.config
make menuconfig
# Pentium-III/Celeron
# http://www.itmedia.co.jp/enterprise/articles/0708/21/news018_2.html
# http://d.hatena.ne.jp/cupnes/20110226/1298713968

export CONCURRENCY_LEVEL=2
export CFLAGS="-march=native -O2"
export CXXFLAGS="$CFLAGS"

make-kpkg clean
time make-kpkg --rootcmd fakeroot --initrd --revision=$(date '+%Y%m%d%H') kernel_image kernel_headers modules_image

cd ..
ls -la
# dpkg -i ...
