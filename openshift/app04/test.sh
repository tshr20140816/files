#!/bin/bash

set -x

cd /tmp

ls -lang

# wget https://github.com/krakjoe/apcu/archive/v4.0.10.zip
# unzip v4.0.10.zip

cd apcu-4.0.10

ls -lang

phpize

ls -lang

./configure --help

exit
