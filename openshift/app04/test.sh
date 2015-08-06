#!/bin/bash

# 1518

set -x

# cd ${OPENSHIFT_DATA_DIR}/openssh
# ./bin/ssh -V

# exit

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

ls -lang ${OPENSHIFT_DATA_DIR}

cd ${OPENSHIFT_DATA_DIR}

cd /tmp

rm -f openssh-6.9p1.tar.gz
rm -f hpn-V_6_9_P1.tar.gz
rm -rf openssh-6.9p1

wget http://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/openssh-6.9p1.tar.gz
wget https://github.com/rapier1/openssh-portable/archive/hpn-V_6_9_P1.tar.gz

ls -lang

tar zxvf openssh-6.9p1.tar.gz
tar zxvf hpn-V_6_9_P1.tar.gz -C ./openssh-6.9p1

cd openssh-6.9p1
ls -lang
./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/openssh \
 --infodir=${OPENSHIFT_TMP_DIR}/gomi \
 --mandir=${OPENSHIFT_TMP_DIR}/gomi \
 --docdir=${OPENSHIFT_TMP_DIR}/gomi \
 --disable-largefile \
 --disable-etc-default-login \
 --disable-utmp \
 --disable-utmpx \
 --disable-wtmp \
 --disable-wtmpx \
 --with-lastlog=${OPENSHIFT_LOG_DIR}/ssh_lastlog.log
time make -j4
make install

cd ${OPENSHIFT_DATA_DIR}/openssh
tree ./

exit

cd /tmp

rm -rf /tmp/gomi
rm -rf gcc
rm -rf gmp*
rm -rf mpfr*
rm -rf mpc*

if [ 1 -eq 1 ]; then
cd /tmp

wget http://ftp.jaist.ac.jp/pub/GNU/gmp/gmp-4.3.2.tar.bz2
tar jxf gmp-4.3.2.tar.bz2
cd gmp-4.3.2
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
fi

cd /tmp

if [ 1 -eq 1 ]; then
wget http://ftp.jaist.ac.jp/pub/GNU/mpfr/mpfr-2.4.2.tar.xz
tar Jxf mpfr-2.4.2.tar.xz
cd mpfr-2.4.2
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static --with-gmp=/tmp/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
fi

cd /tmp

if [ 1 -eq 1 ]; then
wget http://ftp.jaist.ac.jp/pub/GNU/mpc/mpc-1.0.3.tar.gz
tar zxf mpc-1.0.3.tar.gz
cd mpc-1.0.3
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static --with-gmp=/tmp/gcc --with-mpfr=/tmp/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
fi

cd /tmp

time tar Jcf tmp_gcc.tar.xz gcc

tree /tmp/gcc

quota -s
ls -lang
