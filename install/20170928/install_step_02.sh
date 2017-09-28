#!/bin/bash

set -x

# delete default user

sudo userdel -r pi

# uninstall

sudo apt-get -y --purge remove aptitude aptitude-common isc-dhcp-client isc-dhcp-common wireless-regdb wireless-tools wpasupplicant
sudo apt-get -y autoremove
sudo apt-get -y autoclean

