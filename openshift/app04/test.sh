#!/bin/bash

export TZ=JST-9

echo "$(date)"

set -x

ls -lang /tmp
ls -lang $(OPENSHIFT_DATA_DIR)

cd /tmp

[ -f autossh-1.4e.tgz ] || wget http://www.harding.motd.ca/autossh/autossh-1.4e.tgz
