#!/bin/bash

sudo systemctl disable triggerhappy
sudo systemctl disable avahi-daemon
sudo systemctl disable dphys-swapfile
sudo systemctl disable keyboard-setup
sudo systemctl disable plymouth

sudo echo -e "\n" >> /etc/sysctl.conf
sudo echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
