#!/bin/bash

echo "1012"

# set -x

cd /tmp

wget https://github.com/fruux/Baikal/releases/download/0.3.5/baikal-0.3.5.zip

unzip baikal-0.3.5.zip

ls -lang

tree ./

exit
