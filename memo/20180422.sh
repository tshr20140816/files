#!/bin/bash

sudo swapoff --all

sudo systemctl disable triggerhappy
sudo systemctl disable avahi-daemon
sudo systemctl disable dphys-swapfile
sudo systemctl disable keyboard-setup
sudo systemctl disable plymouth

sudo echo -e "\n" >> /etc/sysctl.conf
sudo echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
sudo echo -e "\n" >> /etc/sysctl.conf
sudo sysctl -p

sudo echo -e "\n" >> /etc/systemd/timesyncd.conf
sudo echo "NTP=ntp.jst.mfeed.ad.jp" >> /etc/systemd/timesyncd.conf
sudo echo -e "\n" >> /etc/systemd/timesyncd.conf
sudo systemctl restart systemd-timesyncd

sudo echo -e "\n" >> /etc/fstab
sudo echo "tmpfs /tmp tmpfs defaults 0 0"
sudo echo -e "\n" >> /etc/fstab
sudo echo "tmpfs /var/cache/apt tmpfs defaults 0 0"
sudo echo -e "\n" >> /etc/fstab

sudo echo -e "\n" >> /etc/dhcpcd.conf
sudo echo "interface eth0" >> /etc/dhcpcd.conf
sudo echo -e "\n" >> /etc/dhcpcd.conf
sudo echo "static ip_address=192.168.1.xx/24" >> /etc/dhcpcd.conf
sudo echo -e "\n" >> /etc/dhcpcd.conf
sudo echo "static routers=192.168.1.1" >> /etc/dhcpcd.conf
sudo echo -e "\n" >> /etc/dhcpcd.conf
sudo echo "static domain_name_servers=192.168.1.1 8.8.8.8 1.1.1.1" >> /etc/dhcpcd.conf
