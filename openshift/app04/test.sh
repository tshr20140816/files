#!/bin/bash

echo "1656"

set -x

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

# cp -f $(head -n 1 png_compress_target_list.txt) ./$(basename $(head -n 1 png_compress_target_list.txt))
# time ./optipng/bin/optipng ./$(basename $(head -n 1 png_compress_target_list.txt))
# time ./optipng/bin/optipng -backup -o7 ./$(basename $(head -n 1 png_compress_target_list.txt))

cd /tmp

# for file_name in $(find ${OPENSHIFT_DATA_DIR} -name "*.png" -type f -print)
# do
#     cp -f ${file_name} ./
#     time ./optipng/bin/optipng -backup -o7 $(basename ${file_name})
# done

find ${OPENSHIFT_DATA_DIR} -name "*.png" -type f -print0 | xargs -0i -n 20 ./optipng/bin/optipng -clobber -backup -quiet -o7 {}

ls -lang

exit
