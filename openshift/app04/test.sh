#!/bin/bash

echo "1224"

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

rm -f gcc-4.9.3.tar.bz2
time wget -q http://mirrors.kernel.org/gnu/gcc/gcc-4.9.3/gcc-4.9.3.tar.bz2

time tar jtf gcc-4.9.3.tar.bz2 > file_list.txt

wc -l file_list.txt

grep -v '^gcc-4.9.3.(libobjc|libgfortran|libgo|libjava)' file_list.txt > tmp1.txt
wc -l tmp1.txt
# grep -v ^gcc-4.9.3.libgfortran tmp1.txt > tmp2.txt
# wc -l tmp2.txt
# grep -v ^gcc-4.9.3.libgo tmp2.txt > tmp3.txt
# wc -l tmp3.txt
# grep -v ^gcc-4.9.3.libgomp tmp3.txt > tmp4.txt
# wc -l tmp4.txt
# grep -v ^gcc-4.9.3.libjava tmp4.txt > tmp5.txt
# wc -l tmp5.txt

rm -f *.txt

quota -s

echo "FINISH"
