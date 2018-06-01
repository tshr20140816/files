#!/bin/bash

cd /tmp
rm -f file
wget https://github.com/tshr20140816/hello/raw/master/file

if [ $(cat file) eq '1' ]; then
  sudo apt-get -y upgrade | mail xxx
fi
