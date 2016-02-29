#!/bin/bash

echo "1640"

# set -x

cd /tmp

echo production.log.$(date --date '2 days ago' +%Y%m%d)
echo $(date --date '2 days ago' +%w)

date -d 20160227 '+%w'
date -d 20160228 '+%w'
date -d 20160229 '+%w'

exit
