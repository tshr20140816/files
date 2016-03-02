#!/bin/bash

echo "1435"

# set -x

cd /tmp

dt=$(date --date '2 days ago' +%Y%m%d)
echo ${dt}

exit
