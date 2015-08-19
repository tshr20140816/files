#!/bin/bash

# 1327

set -x

quota -s

ps auwx

exit

rm -rf /tmp/gcc-4.4.7

cd /tmp

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

tree /tmp/gcc

if [ 0 -eq 1 ]; then
rm -rf /tmp/gcc
rm -rf /tmp/gomi

# wget http://ftp.jaist.ac.jp/pub/GNU/gmp/gmp-4.3.2.tar.bz2
tar jxf gmp-4.3.2.tar.bz2
cd gmp-4.3.2
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
rm -rf /tmp/gmp-4.3.2

cd /tmp

# wget http://ftp.jaist.ac.jp/pub/GNU/mpfr/mpfr-2.4.2.tar.xz
tar Jxf mpfr-2.4.2.tar.xz
cd mpfr-2.4.2
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static --with-gmp=/tmp/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
rm -rf /tmp/mpfr-2.4.2

cd /tmp

# wget http://ftp.jaist.ac.jp/pub/GNU/mpc/mpc-1.0.3.tar.gz
tar zxf mpc-1.0.3.tar.gz
cd mpc-1.0.3
./configure --help
./configure --prefix=/tmp/gcc --disable-shared --enable-static --with-gmp=/tmp/gcc --with-mpfr=/tmp/gcc \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
rm -rf /tmp/mpc-1.0.3
fi

cd /tmp

wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.4.7/gcc-core-4.4.7.tar.bz2
wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.4.7/gcc-g++-4.4.7.tar.bz2

tar jxf gcc-core-4.4.7.tar.bz2
tar jxf gcc-g++-4.4.7.tar.bz2

ls -lang

cd gcc-4.4.7
./configure --help
./configure --with-gmp=/tmp/gcc --with-mpfr=/tmp/gcc --prefix=/tmp/gcc4 \
 --infodir=/tmp/gomi --mandir=/tmp/gomi
nohup make -j2 > makelog.log
make install
rm -rf /tmp/gcc-4.4.7

tree /tmp/gcc4

quota -s
exit

cd /tmp

build_server_password=$(head -n 1 p1.txt)

# ***** build request *****

apache_version=2.2.31
ruby_version=2.1.7
libmemcached_version=1.0.18
delegate_version=9.9.13
tcl_version=8.6.3
cadaver_version=0.23.3
php_version=5.6.12

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cat << '__HEREDOC__' > build_request.xml
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <passsword value="__PASSWORD__" />
  <uuid value="__UUID__" />
  <data_dir value="__DATA_DIR__" />
  <tmp_dir value="__TMP_DIR__" />
  <items>
    <item app="apache" version="__APACHE_VERSION__" />
    <item app="ruby" version="__RUBY_VERSION__" />
    <item app="libmemcached" version="__LIBMEMCACHED_VERSION__" />
    <item app="delegate" version="__DELEGATE_VERSION__" />
    <item app="tcl" version="__TCL_VERSION__" />
    <item app="cadaver" version="__CADAVER_VERSION__" />
    <item app="php" version="__PHP_VERSION__" />
  </items>
</root>
__HEREDOC__
sed -i -e "s|__PASSWORD__|${build_server_password}|g" build_request.xml
sed -i -e "s|__UUID__|${OPENSHIFT_APP_UUID}|g" build_request.xml
sed -i -e "s|__DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" build_request.xml
sed -i -e "s|__TMP_DIR__|${OPENSHIFT_TMP_DIR}|g" build_request.xml
sed -i -e "s|__APACHE_VERSION__|${apache_version}|g" build_request.xml
sed -i -e "s|__RUBY_VERSION__|${ruby_version}|g" build_request.xml
sed -i -e "s|__LIBMEMCACHED_VERSION__|${libmemcached_version}|g" build_request.xml
sed -i -e "s|__DELEGATE_VERSION__|${delegate_version}|g" build_request.xml
sed -i -e "s|__TCL_VERSION__|${tcl_version}|g" build_request.xml
sed -i -e "s|__CADAVER_VERSION__|${cadaver_version}|g" build_request.xml
sed -i -e "s|__PHP_VERSION__|${php_version}|g" build_request.xml

mirror_server="https://files4-20150524.rhcloud.com/files/"
mirror_server="https://files3-20150207.rhcloud.com/files/"

if [ ${build_server_password} != 'none' ]; then
    wget --post-file=build_request.xml ${mirror_server}build_action.php -O -
fi
popd > /dev/null

exit

cd /tmp

rm -f jessie*.txt

wget https://packages.debian.org/jessie-backports/allpackages?format=txt.gz -O jessie_backports.txt.gz

gunzip jessie_backports.txt.gz

wc -l jessie_backports.txt

head jessie_backports.txt

# cat jessie_backports.txt | grep -v "virtual package" > jessie_backports.txt
# cat jessie_backports.txt | grep -v "virtual package"
grep -v "virtual package" jessie_backports.txt > jessie_backports2.txt
# grep -v "virtual package" jessie_backports.txt

wc -l jessie_backports2.txt

tail -n +5 jessie_backports2.txt > jessie_backports.txt

wc -l jessie_backports.txt

# cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 100 | head -n 1 > aa.txt


ls -lang

exit

# cd ${OPENSHIFT_DATA_DIR}/openssh
# ./bin/ssh -V

# exit

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

ls -lang ${OPENSHIFT_DATA_DIR}

cd ${OPENSHIFT_DATA_DIR}

cd /tmp

rm -rf ${OPENSHIFT_DATA_DIR}/openssh
rm -f openssh-6.9p1.tar.gz
rm -f hpn-V_6_9_P1.tar.gz
rm -rf openssh-6.9p1

wget http://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/openssh-6.9p1.tar.gz
wget https://github.com/rapier1/openssh-portable/archive/hpn-V_6_9_P1.tar.gz

ls -lang

tar zxf openssh-6.9p1.tar.gz
tar zxf hpn-V_6_9_P1.tar.gz
cp -rf openssh-portable-hpn-V_6_9_P1/* openssh-6.9p1/

cd openssh-6.9p1/
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

cd ${OPENSHIFT_DATA_DIR}/openssh
./bin/ssh -V

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
