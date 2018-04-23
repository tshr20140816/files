#!/bin/bash

sudo apt-get -y install apache2
sudo apt-get -y install postgresql-9.6 php7.0 rsyslog-gnutls php7.0-pgsql php7.0-mbstring php7.0-xml git

curl -O https://www.loggly.com/install/configure-linux.sh
