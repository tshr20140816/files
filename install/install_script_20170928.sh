#!/bin/bash

set -x

# ex sh ./install_script_20170928.sh 192.168.1.21 user

# ${1} server ipaddress 0.0.0.0
# ${2} user

if [ $# -ne 2 ]; then
  echo "arg1 : server ipaddress 0.0.0.0"
  echo "arg2 : user"
  exit
fi

# apt

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo vcgencmd version

# ip address

sudo cat << "__HEREDOC__" > /etc/dhcpcd.conf

interface eth0
static ip_address= ${1}/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8
__HEREDOC__

# uninstall

# sudo apt-get -y --purge remove aptitude aptitude-common isc-dhcp-client isc-dhcp-common wireless-regdb wireless-tools wpasupplicant
# sudo apt-get -y autoremove
# sudo apt-get -y autoclean

# telnet vi

sudo apt-get -y install telnetd vim

# etc

sudo timedatectl set-timezone Asia/Tokyo
sudo timedatectl 

# $ sudo raspi-config
# Advanced Options->Memory Split

# user

sudo useradd ${2}
sudo gpasswd -a ${2} sudo

# /etc/systemd/timesyncd.conf
# NTP=ntp.jst.mfeed.ad.jp
date

# sudo systemctl restart systemd-timesyncd

# sudo passwd root
# sudo visudo

# reboot
