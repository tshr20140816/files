#!/bin/bash

mkdir -p /usr/src
cd /usr/src

apt-get update
apt-get install telnetd sudo vim

# apt-get install gcc
apt-get install build-essential fakeroot kernel-package libncurses5-dev
apt-get source linux
apt-get build-dep linux

ls -lang /boot/config*

exit
cp /boot/config- ./.config
make menuconfig
# Pentium-III/Celeron
# http://www.itmedia.co.jp/enterprise/articles/0708/21/news018_2.html
# http://d.hatena.ne.jp/cupnes/20110226/1298713968

export CONCURRENCY_LEVEL=1
export CFLAGS="-march=native -O2"
export CXXFLAGS="$CFLAGS"

make-kpkg clean
time make-kpkg --initrd --revision=20150719 kernel_image kernel_headers
