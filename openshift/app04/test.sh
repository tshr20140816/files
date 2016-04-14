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

ls -lang

cd $OPENSHIFT_DATA_DIR

cd gcc-4.9.3
rm -rf work
mkdir work
cd work
../configure --help
../configure --with-gmp=$OPENSHIFT_DATA_DIR/gcc --with-mpfr=$OPENSHIFT_DATA_DIR/gcc --prefix=$OPENSHIFT_DATA_DIR/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --disable-multilib --enable-stage1-languages=c,c++ \
 --enable-stage1-checking=c,c++ target=x86_64-unknown-linux-gnu \
 --disable-shared --enable-static \
 --program-suffix=-493 \
 --disable-libjava --disable-libgo --disable-libgfortran --enable-languages=c,c++
quota -s
time make
quota -s
make install

quota -s

exit

cd $OPENSHIFT_DATA_DIR

rm -f gcc-4.9.3.tar.bz2*
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
   set +x
   [ -f ${file_name} ] && continue
   set -x
   echo "${file_name}" >> tmp1.txt
   set +x
done
set -x
wc -l tmp1.txt
rm file_list.txt
mv tmp1.txt file_list.txt

if [ $(cat file_list.txt | wc -l) -gt 1 ]; then
    cat file_list.txt | xargs -P1 -n5000 tar jxvf gcc-4.9.3.tar.bz2
fi

tree ./

quota -s

echo "FINISH"
