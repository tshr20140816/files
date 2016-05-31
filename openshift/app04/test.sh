#!/bin/bash

echo "1142"

set -x

quota -s
oo-cgroup-read memory.failcnt
echo "$(oo-cgroup-read memory.usage_in_bytes)" | awk '{printf "%\047d\n", $0}'

# oo-cgroup-read all
# oo-cgroup-read report

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

/usr/bin/gear start --trace

cd /tmp
ls -lang
cd $OPENSHIFT_DATA_DIR
ls -lang
ls -lang $OPENSHIFT_REPO_DIR

quota -s

# -----

cd /tmp
rm -rf gmp-4.3.2 mpc-0.8.2 mpfr-2.4.2 openssh-6.9p1 bin info 20160523 gomi

cd $OPENSHIFT_DATA_DIR
rm -rf ssh
rm -rf local

find / -name libc.so.6 -print 2>/dev/null

# -----

# convert --help

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd /tmp
cd ${OPENSHIFT_TMP_DIR}

gmp_version=4.3.2

wget -nc -q http://ftp.jaist.ac.jp/pub/GNU/gmp/gmp-${gmp_version}.tar.bz2
rm -rf gmp-${gmp_version}
tar xf gmp-${gmp_version}.tar.bz2
cd gmp-${gmp_version}
./configure \
 --mandir=${OPENSHIFT_TMP_DIR}/gomi \
 --infodir=${OPENSHIFT_TMP_DIR}/gomi \
 --prefix=${OPENSHIFT_DATA_DIR}/local
time make -j4
make install

cd ${OPENSHIFT_TMP_DIR}

mpfr_version=2.4.2

wget -nc -q http://mpfr.loria.fr/mpfr-${mpfr_version}/mpfr-${mpfr_version}.tar.bz2
rm -rf mpfr-${mpfr_version}
tar xf mpfr-${mpfr_version}.tar.bz2
cd mpfr-${mpfr_version}
./configure  \
 --mandir=${OPENSHIFT_TMP_DIR}/gomi \
 --infodir=${OPENSHIFT_TMP_DIR}/gomi \
 --prefix=${OPENSHIFT_DATA_DIR}/local \
 --disable-maintainer-mode
time make -j4
make install

cd ${OPENSHIFT_TMP_DIR}

mpc_version=0.8.2

rm -rf mpc-${mpc_version}
wget -nc -q http://www.multiprecision.org/mpc/download/mpc-${mpc_version}.tar.gz
rm -rf mpc-${mpc_version}
tar xf mpc-${mpc_version}.tar.gz
cd mpc-${mpc_version}
./configure  \
 --mandir=${OPENSHIFT_TMP_DIR}/gomi \
 --infodir=${OPENSHIFT_TMP_DIR}/gomi \
 --prefix=${OPENSHIFT_DATA_DIR}/local \
 --with-mpfr=${OPENSHIFT_DATA_DIR}/local \
 --with-gmp=${OPENSHIFT_DATA_DIR}/local
time make -j4
make install

cd ${OPENSHIFT_TMP_DIR}

rm -rf gmp-${gmp_version}
rm -rf mpfr-${mpfr_version}
rm -rf mpc-${mpc_version}

# tree ${OPENSHIFT_DATA_DIR}/local

wget -q -nc http://mirrors.concertpass.com/gcc/releases/gcc-4.4.7/gcc-core-4.4.7.tar.bz2
tar xf gcc-core-4.4.7.tar.bz2
ls -lang
cd gcc*
./configure \
 --with-mpc=${OPENSHIFT_DATA_DIR}/local/ \
 --with-mpfr=${OPENSHIFT_DATA_DIR}/local \
 --with-gmp=${OPENSHIFT_DATA_DIR}/local \
 --disable-libquadmath \
 --disable-libquadmath-support


rm -rf ${OPENSHIFT_DATA_DIR}/local

quota -s
echo "FINISH"
exit
