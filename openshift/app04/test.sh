#!/bin/bash

echo "1603"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

rm -f *.png
rm -f *.png.bak

ls -lang

# optipng_version="0.7.5"
# rm -f  optipng-${optipng_version}.tar.gz
# rm -rf optipng*
# wget http://downloads.sourceforge.net/project/optipng/OptiPNG/optipng-${optipng_version}/optipng-${optipng_version}.tar.gz

# tar xfz optipng-${optipng_version}.tar.gz

./optipng/bin/optipng --help

cp -f $(head -n 1 png_compress_target_list.txt) ./$(basename $(head -n 1 png_compress_target_list.txt))
time ./optipng/bin/optipng ./$(basename $(head -n 1 png_compress_target_list.txt)

ls -lang

exit
