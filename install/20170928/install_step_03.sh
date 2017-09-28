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

cd /var/www/443

mkdir ttrss
cd ttrss
ln -s /var/www/80/ttrss/api api
ln -s /var/www/80/ttrss/classes classes
ln -s /var/www/80/ttrss/css css
ln -s /var/www/80/ttrss/images images
ln -s /var/www/80/ttrss/include include
ln -s /var/www/80/ttrss/install install
ln -s /var/www/80/ttrss/js js
ln -s /var/www/80/ttrss/lib lib
ln -s /var/www/80/ttrss/locale locale
ln -s /var/www/80/ttrss/plugins plugins
ln -s /var/www/80/ttrss/plugins.local plugins.local
ln -s /var/www/80/ttrss/schema schema
ln -s /var/www/80/ttrss/templates templates
ln -s /var/www/80/ttrss/tests tests
ln -s /var/www/80/ttrss/themes themes
ln -s /var/www/80/ttrss/themes.local themes.local
ln -s /var/www/80/ttrss/utils utils
ln -s /var/www/80/ttrss/atom-to-html.xsl atom-to-html.xsl
ln -s /var/www/80/ttrss/backend.php backend.php
ln -s /var/www/80/ttrss/config.php-dist config.php-dist
ln -s /var/www/80/ttrss/errors.php errors.php
ln -s /var/www/80/ttrss/index.php index.php
ln -s /var/www/80/ttrss/messages.pot messages.pot
ln -s /var/www/80/ttrss/opml.php opml.php
ln -s /var/www/80/ttrss/prefs.php prefs.php
ln -s /var/www/80/ttrss/public.php public.php
ln -s /var/www/80/ttrss/register.php register.php
ln -s /var/www/80/ttrss/update.php update.php
ln -s /var/www/80/ttrss/update_daemon2.php update_daemon2.php
mkdir -m 777 cache
mkdir -m 777 cache/images
mkdir -m 777 cache/upload
mkdir -m 777 cache/export
mkdir -m 777 cache/js
mkdir -m 777 feed-icons
mkdir -m 777 lock
touch feed-icons/index.html

# noip

cd /usr/local/src
wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
tar xzf noip-duc-linux.tar.gz
cd noip-*
make
make install
