#!/bin/bash

set -x

cd /tmp

quota -s

wget http://download.fedora.redhat.com/pub/fedora/linux/updates/21/x86_64/g/gcc-4.9.2-6.fc21.x86_64.rpm
