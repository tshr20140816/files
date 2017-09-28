#!/bin/bash

# root user

set -x

# ttrss

cd /var/www/80

sudo git clone --depth 1 https://tt-rss.org/git/tt-rss.git ttrss

cd ttrss
sudo chmod -R 777 cache/images
sudo chmod -R 777 cache/upload
sudo chmod -R 777 cache/export
sudo chmod -R 777 cache/js
sudo chmod -R 777 feed-icons
sudo chmod -R 777 lock

# noip

cd /usr/local/src
wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
tar xzf noip-duc-linux.tar.gz
cd noip-*
make
make install
