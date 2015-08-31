#!/bin/bash

set -x

quota -s

cd /tmp

wget http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.7.tar.xz

tar Jxf squid-3.5.7.tar.xz

cd squid-3.5.7

./configure --help
