#!/bin/bash

echo "1621"

set -x

quota -s
oo-cgroup-read memory.failcnt

# oo-cgroup-read all
# oo-cgroup-read report

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

rm -rf gcc-4.9.3

ls -lang

rm -f gcc-4.9.3.tar.bz2

exit

time wget -q http://mirrors.kernel.org/gnu/gcc/gcc-4.9.3/gcc-4.9.3.tar.bz2

time tar jtf gcc-4.9.3.tar.bz2 > file_list.txt

wc -l file_list.txt

grep -v -E '^gcc-4.9.3.(libobjc|libgfortran|libgo|libjava)' file_list.txt > tmp1.txt
wc -l tmp1.txt
grep -v '/$' tmp1.txt > file_list.txt
wc -l file_list.txt

rm -f tmp*.txt

for file_name in $(cat file_list.txt)
do
    tar jxvf gcc-4.9.3.tar.bz2 ${file_name}
done

tree ./

quota -s

echo "FINISH"
