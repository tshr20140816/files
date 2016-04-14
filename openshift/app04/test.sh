#!/bin/bash

echo "1527"

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

cd /tmp

[ ! -f gmp-4.3.2.tar.bz2 ] && wget http://mirrors.kernel.org/gnu/gmp/gmp-4.3.2.tar.bz2
rm -rf gmp-4.3.2
tar jxf gmp-4.3.2.tar.bz2
cd gmp-4.3.2
./configure --help
./configure --prefix=$OPENSHIFT_DATA_DIR/gcc --disable-shared --enable-static \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j2
make install
cd /tmp
rm -rf gmp-4.3.2
rm -f gmp-4.3.2.tar.bz2

cd /tmp

[ ! -f mpfr-2.4.2.tar.xz ] && wget http://mirrors.kernel.org/gnu/mpfr/mpfr-2.4.2.tar.xz
rm -rf mpfr-2.4.2
tar Jxf mpfr-2.4.2.tar.xz
cd mpfr-2.4.2
./configure --help
./configure --prefix=$OPENSHIFT_DATA_DIR/gcc --disable-shared --enable-static --with-gmp=$OPENSHIFT_DATA_DIR/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j2
make install
cd /tmp
rm -rf mpfr-2.4.2
rm -f mpfr-2.4.2.tar.xz
cd /tmp

[ ! -f mpc-1.0.3.tar.gz ] && wget http://mirrors.kernel.org/gnu/mpc/mpc-1.0.3.tar.gz
rm -rf mpc-1.0.3
tar zxf mpc-1.0.3.tar.gz
cd mpc-1.0.3
./configure --help
./configure --prefix=$OPENSHIFT_DATA_DIR/gcc --disable-shared --enable-static --with-gmp=$OPENSHIFT_DATA_DIR/gcc --with-mpfr=$OPENSHIFT_DATA_DIR/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
cd /tmp
rm -rf mpc-1.0.3
rm -f mpc-1.0.3.tar.gz
rm -rf gomi

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
