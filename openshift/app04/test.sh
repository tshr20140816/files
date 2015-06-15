#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log
# 0112

export TZ=JST-9

echo "$(date)"

set -x

# find / -name "libxml*" -print 2>/dev/null

wc -l ${OPENSHIFT_LOG_DIR}/php_install.log
wc -l ${OPENSHIFT_LOG_DIR}/distcc_ssh.log

df -ih

rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log.*
rm -f ${OPENSHIFT_LOG_DIR}/ccache.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
rm -f ${OPENSHIFT_TMP_DIR}/cc*.s
rm -f ${OPENSHIFT_TMP_DIR}/distcc_server_stderr_*

rm -f  ${OPENSHIFT_DATA_DIR}/.distcc/lock/backoff*

mkdir ${OPENSHIFT_DATA_DIR}/.ssh 2>/dev/null
mkdir ${OPENSHIFT_TMP_DIR}/.ssh 2>/dev/null
cat << __HEREDOC__ > ${OPENSHIFT_DATA_DIR}/.ssh/config
Host *
  IdentityFile __OPENSHIFT_DATA_DIR__.ssh/id_rsa
  StrictHostKeyChecking no
  BatchMode yes
  UserKnownHostsFile /dev/null
  LogLevel QUIET
#  LogLevel DEBUG3
  Protocol 2
  Ciphers arcfour256,arcfour128
  AddressFamily inet
#  PreferredAuthentications publickey,gssapi-with-mic,hostbased,keyboard-interactive,password
  PreferredAuthentications publickey
  PasswordAuthentication no
  GSSAPIAuthentication no
  ConnectionAttempts 5
  ControlMaster auto
  # ControlPath too long
#  ControlPath __OPENSHIFT_DATA_DIR__.ssh/master-%r@%h:%p
  ControlPath __OPENSHIFT_TMP_DIR__.ssh/master-%r@%h:%p
  ControlPersist 30m
  ServerAliveInterval 60
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" ${OPENSHIFT_DATA_DIR}/.ssh/config
sed -i -e "s|__OPENSHIFT_TMP_DIR__|${OPENSHIFT_TMP_DIR}|g" ${OPENSHIFT_DATA_DIR}/.ssh/config

mkdir ${OPENSHIFT_DATA_DIR}/bin 2>/dev/null
pushd ${OPENSHIFT_DATA_DIR}/bin > /dev/null
cat << '__HEREDOC__' > distcc-ssh
#!/bin/bash

export TZ=JST-9
export HOME=${OPENSHIFT_DATA_DIR}
echo "$(date +%Y/%m/%d" "%H:%M:%S) $@" >> ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
exec ssh -F ${OPENSHIFT_DATA_DIR}/.ssh/config $@
__HEREDOC__
chmod +x distcc-ssh
popd > /dev/null

export LD=ld.gold
export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
export PATH="${OPENSHIFT_TMP_DIR}/local/bin:$PATH"
export PATH="${OPENSHIFT_TMP_DIR}/bison/bin:$PATH"
export PATH="${OPENSHIFT_TMP_DIR}/re2c/bin:$PATH"
# export PATH="${OPENSHIFT_DATA_DIR}/local/bin:$PATH"
# export LD_LIBRARY_PATH="${OPENSHIFT_DATA_DIR}/local/lib"
export LD_LIBRARY_PATH="/tmp/local/lib:/tmp/libxml2/lib"
# export INCLUDE="${OPENSHIFT_DATA_DIR}/local/include"

cd ${OPENSHIFT_DATA_DIR}/ccache/bin 
ln -s ccache cc
ln -s ccache gcc
unlink cc
unlink gcc
export CC="ccache gcc"
export CXX="ccache g++"

# export CCACHE_PREFIX=distcc
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=/dev/null
# export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_MAXSIZE=300M

distcc_hosts_string="55630afc5973caf283000214@v1-20150216.rhcloud.com/4:/var/lib/openshift/55630afc5973caf283000214/app-root/data/distcc/bin/distccd_start"
distcc_hosts_string="${distcc_hosts_string} 55630b63e0b8cd7ed000007f@v2-20150216.rhcloud.com/4:/var/lib/openshift/55630b63e0b8cd7ed000007f/app-root/data/distcc/bin/distccd_start"
distcc_hosts_string="${distcc_hosts_string} 55630c675973caf283000251@v3-20150216.rhcloud.com/4:/var/lib/openshift/55630c675973caf283000251/app-root/data/distcc/bin/distccd_start"
export DISTCC_HOSTS="${distcc_hosts_string}"

# export DISTCC_LOG=/dev/null
export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc.log
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
export DISTCC_SSH="${OPENSHIFT_DATA_DIR}/bin/distcc-ssh"

export HOME=${OPENSHIFT_DATA_DIR}

# export CFLAGS="-O2 -march=core2 -maes -mavx -mcx16 -mpclmul -mpopcnt -msahf"
# export CFLAGS="${CFLAGS} -msse -msse2 -msse3 -msse4 -msse4.1 -msse4.2 -mssse3 -mtune=generic"
# export CFLAGS="${CFLAGS} -pipe -fomit-frame-pointer -s"

export CFLAGS="-I/tmp/local/include -I/tmp/libxml2/include"
export CFLAGS="${CFLAGS} -O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

ccache -s
ccache --zero-stats
ccache --print-config

if [ 1 -eq 0 ]; then
cd /tmp
build_server_password=$(cat aa.txt)

# cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 100 | head -n 1 > testdata.txt
# cat testdata.txt

# ***** build request *****

apache_version=2.2.29
ruby_version=2.1.6
libmemcached_version=1.0.18
delegate_version=9.9.13
tcl_version=8.6.3
cadaver_version=0.23.3
php_version=5.6.10

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

mirror_server="https://files3-20150207.rhcloud.com/files/"

if [ ${build_server_password} != 'none' ]; then
    wget --post-file=build_request.xml ${mirror_server}build_action.php -O -
fi
popd > /dev/null
fi

# kokokara

cd /tmp

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

if [ 1 -eq 0 ]; then
cd /tmp
[ -f bison-2.7.1.tar.xz ] || wget http://ftp.jaist.ac.jp/pub/GNU/bison/bison-2.7.1.tar.xz
rm -rf bison-2.7.1
tar Jxf bison-2.7.1.tar.xz
cd bison-2.7.1
./configure --help
./configure --prefix=/tmp/bison --disable-dependency-tracking --disable-largefile
time make
make install
fi

if [ 1 -eq 0 ]; then
cd /tmp
[ -f re2c-0.14.3.tar.gz ] || wget http://downloads.sourceforge.net/project/re2c/re2c/0.14.3/re2c-0.14.3.tar.gz
rm -rf re2c-0.14.3
tar zxf re2c-0.14.3.tar.gz
cd re2c-0.14.3
./configure --help
./configure --prefix=/tmp/re2c --disable-dependency-tracking
time make
make install
fi

if [ 1 -eq 0 ]; then
cd /tmp
rm -rf /tmp/libxml2
[ -f libxml2-2.7.6.tar.gz ] || wget ftp://xmlsoft.org/libxml2/libxml2-2.7.6.tar.gz
rm -rf libxml2-2.7.6
tar zxf libxml2-2.7.6.tar.gz
cd libxml2-2.7.6
./configure --help
./configure --prefix=/tmp/libxml2 \
 --with-debug=off \
 --disable-dependency-tracking \
 --infodir=/tmp/info \
 --mandir=/tmp/man \
 --docdir=/tmp/doc \
 --enable-rebuild-docs=no \
 --enable-ipv6=no > /dev/null
time make > /dev/null
make install
tree /tmp/libxml2
fi

cd /tmp

ccache -s
# export CCACHE_READONLY=true
oo-cgroup-read memory.failcnt

echo "$(date +%Y/%m/%d" "%H:%M:%S) php"

install_dir=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 10 | head -n 1)

php_version=5.6.10

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

rm -rf php-${php_version}
# rm -f php-${php_version}.tar.xz
# wget http://jp1.php.net/get/php-${php_version}.tar.xz/from/this/mirror -O php-${php_version}.tar.xz
# [ -f php-${php_version}.tar.xz ] || wget http://jp1.php.net/get/php-${php_version}.tar.xz/from/this/mirror -O php-${php_version}.tar.xz
tar Jxf php-${php_version}.tar.xz
pushd ${OPENSHIFT_TMP_DIR}/php-${php_version} > /dev/null
./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/${install_dir} \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --with-apxs2=${OPENSHIFT_DATA_DIR}/apache/bin/apxs \
 --with-mysql \
 --with-pdo-mysql \
 --without-sqlite3 \
 --without-pdo-sqlite \
 --without-cdb \
 --without-pear \
 --with-curl \
 --with-bz2 \
 --with-iconv \
 --with-openssl \
 --with-zlib \
 --with-gd \
 --enable-exif \
 --enable-ftp \
 --enable-xml \
 --enable-mbstring \
 --enable-sockets \
 --disable-ipv6 \
 --disable-phar \
 --disable-inifile \
 --disable-flatfile \
 --with-libxml-dir=/tmp/libxml2 \
 --with-gettext=${OPENSHIFT_DATA_DIR}/${install_dir} \
 --with-zend-vm=GOTO > ${OPENSHIFT_LOG_DIR}/php_install.log
# --with-libdir=lib64 
# --enable-mbregex
echo "$(date)"
# time make -j4 >> /tmp/php_install.log
time make -j8 >> ${OPENSHIFT_LOG_DIR}/php_install.log &
pid=$!
timer=48
while [ $timer -gt 0 ]
do
    if ps -p $! >/dev/null 2>&1; then
        sleep 10
        timer=$(($timer - 1))
        continue
    else
        break
    fi
done
if [ $timer -le 0 ] ; then
    echo "# TEST" >> ${OPENSHIFT_DATA_DIR}/test.sh
fi
popd > /dev/null
popd > /dev/null

ccache -s
oo-cgroup-read memory.failcnt
wait
