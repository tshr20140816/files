#!/bin/bash

sudo userdel -r pi

sudo apt-get -y --purge remove aptitude aptitude-common isc-dhcp-client isc-dhcp-common wireless-regdb wireless-tools wpasupplicant bluez bluez-firmware pi-bluetooth

sudo apt-get -y autoremove
sudo apt-get -y autoclean

sudo apt-get clean
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get dist-upgrade

sudo apt-get -y install telnetd vim
sudo systemctl disable ssh.service

sudo reboot
