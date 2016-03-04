#!/bin/bash

echo "1603"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

ls -lang

# optipng_version="0.7.5"
# rm -f  optipng-${optipng_version}.tar.gz
# rm -rf optipng*
# wget http://downloads.sourceforge.net/project/optipng/OptiPNG/optipng-${optipng_version}/optipng-${optipng_version}.tar.gz

# tar xfz optipng-${optipng_version}.tar.gz

./optipng/bin/optipng --help

exit
