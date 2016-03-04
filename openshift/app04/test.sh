#!/bin/bash

echo "1603"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

rm -f *.js*

ls -lang

optipng_version="0.7.5"
rm -f  optipng-${optipng_version}.tar.gz
rm -rf optipng*
wget http://downloads.sourceforge.net/project/optipng/OptiPNG/optipng-${optipng_version}/optipng-${optipng_version}.tar.gz

tar xfz optipng-${optipng_version}.tar.gz

cd optipng*
./configure --prefix=/tmp/optipng
time make -j4
make install

cd /tmp

rm -rf optipng-*
rm -f  optipng-${optipng_version}.tar.gz

find ${OPENSHIFT_DATA_DIR} -name "*.png" -mindepth 2 -type f -print | tee -a ./png_compress_target_list.txt

cat ./png_compress_target_list.txt

ls -lang optipng
ls -lang optipng/bin

tree optipng

exit
