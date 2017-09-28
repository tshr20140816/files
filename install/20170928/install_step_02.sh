#!/bin/bash

set -x

# delete default user

sudo userdel -r pi

# uninstall

sudo apt-get -y --purge remove aptitude aptitude-common isc-dhcp-client isc-dhcp-common wireless-regdb wireless-tools wpasupplicant
sudo apt-get -y autoremove
sudo apt-get -y autoclean

# 

time sudo apt-get -y install postgresql apache2 php php-pgsql php-mbstring php-xml git

# apache

cd /etc/apache2
sudo mv apache2.conf apache2.conf.org
sudo wget https://github.com/tshr20140816/files/raw/master/apache24/sample1.conf
sudo mv sample1.conf apache2.conf

mkdir -p /var/www/80
mkdir -p /var/www/443
mkdir -p /var/www/10080

cd ~
openssl genrsa 2048 > server.key
openssl req -new -key server.key > server.csr
openssl x509 -days 3650 -req -sha256 -signkey server.key < server.csr > server.crt

rm server.csr
sudo mv server.key /etc/apache2/
sudo mv server.crt /etc/apache2/

# heroku

cd ~

sudo apt-get -y install nodejs npm git
sudo npm update -g npm
sudo npm cache clean
sudo npm install -g n
sudo n stable
node --version
npm --version
time sudo npm install -g heroku-cli

# delegate

cd ~

wget http://delegate.hpcc.jp/anonftp/DeleGate/delegate9.9.13.tar.gz
tar xfz delegate9.9.13.tar.gz
cd delegate9.9.13
export CFLAGS='-mcpu=arm1176jzf-s -mfpu=vfp -Wno-error=narrowing'
export CXXFLAGS="${CFLAGS}"
time make -j1 ADMIN="admin@localhost"

