#!/bin/bash

echo "1107"

set -x

quota -s
oo-cgroup-read memory.failcnt

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

# tree -a ${OPENSHIFT_DATA_DIR}
# exit

/usr/bin/gear start --trace

# shopt

cd /tmp

ls -lang

date

curl -r -20000000 http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.9.3/gcc-4.9.3.tar.bz2 -O gcc-4.9.3.tar.bz2-1 &
curl -r 20000001-40000000 http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.9.3/gcc-4.9.3.tar.bz2 -O gcc-4.9.3.tar.bz2-2 &
curl -r 40000001- http://mirrors.kernel.org/gnu/gcc/gcc-4.9.3/gcc-4.9.3.tar.bz2 -O gcc-4.9.3.tar.bz2-3 &

wait

date

ls -lang

rm -f gcc-4.9.3.tar.bz2-*

exit

rm -f gcc-4.9.3.tar.bz2
time wget -q http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.9.3/gcc-4.9.3.tar.bz2
# http://ftp.jaist.ac.jp/pub/GNU/gcc/gcc-4.9.3/gcc-4.9.3.tar.bz2
# http://mirrors.kernel.org/gnu/gcc/gcc-4.9.3/gcc-4.9.3.tar.bz2

time tar jtf gcc-4.9.3.tar.bz2 > file_list.txt

rm -f file_list.zip
zip file_list.zip file_list.txt
mv file_list.zip $OPENSHIFT_REPO_DIR/file_list.zip

quota -s

echo "FINISH"
