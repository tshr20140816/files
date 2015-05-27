#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# 555781ad4382ece1eb00005e@b4-20150514.rhcloud.com
# 555782f44382ecdc6d00003b@b5-20150514.rhcloud.com
# 5557844c4382ecd6b00000f8@b6-20150514.rhcloud.com

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

gcc --help
gcc --version

cd /tmp

# whereis clang
whereis python

oo-cgroup-read memory.failcnt

export HOME=$OPENSHIFT_DATA_DIR
cd .ssh
cat << '__HEREDOC__' > config
Host *
  IdentityFile __OPENSHIFT_DATA_DIR__.ssh/id_rsa
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel QUIET
#  LogLevel DEBUG3
  Protocol 2
  PasswordAuthentication no
  ConnectionAttempts 5
  ControlMaster auto
  ControlPath /tmp/.ssh/master-%r@%h:%p
  ControlPersist 1800s
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" config

ssh -24n -F config 55630afc5973caf283000214@v1-20150216.rhcloud.com ls -al app-root/logs
ssh -24n -F config 55630afc5973caf283000214@v1-20150216.rhcloud.com quota -s
# ssh -24n -F config 55630b63e0b8cd7ed000007f@v2-20150216.rhcloud.com pwd
# ssh -24n -F config 55630c675973caf283000251@v3-20150216.rhcloud.com pwd
# ssh -24n -F config 555894314382ec8df40000e1@b1-20150430.rhcloud.com pwd
# ssh -24n -F config 555895235973ca539500007e@b2-20150430.rhcloud.com pwd
# ssh -24n -F config 555895dbfcf9337761000009@b3-20150430.rhcloud.com pwd
ps auwx | grep ssh

mkdir ${OPENSHIFT_DATA_DIR}/bin 2>/dev/null
pushd ${OPENSHIFT_DATA_DIR}/bin > /dev/null
cat << '__HEREDOC__' > distcc-ssh
#!/bin/bash

# echo "$(date +%Y/%m/%d" "%H:%M:%S) $@" >> ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
exec /usr/bin/ssh -24n -F /tmp/.ssh/config $@
__HEREDOC__
chmod +x distcc-ssh
popd > /dev/null

grep -e ERROR /tmp/distcc.log
wc -l /tmp/distcc.log
rm -f /tmp/distcc.log

oo-cgroup-read memory.failcnt

echo $(date)

export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
# export DISTCC_LOG=/dev/null
export DISTCC_LOG=/tmp/distcc.log
export CC="distcc gcc"
export CXX="distcc g++"
export CFLAGS="-O2 -march=x86-64 -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"
export MAKEOPTS="-j 10"
export DISTCC_HOSTS="localhost/1 55630afc5973caf283000214@v1-20150216.rhcloud.com/2:/var/lib/openshift/55630afc5973caf283000214/app-root/data/distcc/bin/distccd_start,cpp 55630b63e0b8cd7ed000007f@v2-20150216.rhcloud.com/2:/var/lib/openshift/55630b63e0b8cd7ed000007f/app-root/data/distcc/bin/distccd_start,cpp 55630c675973caf283000251@v3-20150216.rhcloud.com/2:/var/lib/openshift/55630c675973caf283000251/app-root/data/distcc/bin/distccd_start,cpp 555894314382ec8df40000e1@b1-20150430.rhcloud.com/2:/var/lib/openshift/555894314382ec8df40000e1/app-root/data/distcc/bin/distccd_start,cpp 555895235973ca539500007e@b2-20150430.rhcloud.com/2:/var/lib/openshift/555895235973ca539500007e/app-root/data/distcc/bin/distccd_start,cpp 555895dbfcf9337761000009@b3-20150430.rhcloud.com/2:/var/lib/openshift/555895dbfcf9337761000009/app-root/data/distcc/bin/distccd_start,cpp 555f3483500446724c000127@b7-20150522.rhcloud.com/2:/var/lib/openshift/555f3483500446724c000127/app-root/data/distcc/bin/distccd_start,cpp 555f387de0b8cd419e0000cc@b8-20150522.rhcloud.com/2:/var/lib/openshift/555f387de0b8cd419e0000cc/app-root/data/distcc/bin/distccd_start,cpp 555f34eae0b8cd8b2400001e@b9-20150522.rhcloud.com/2:/var/lib/openshift/555f34eae0b8cd8b2400001e/app-root/data/distcc/bin/distccd_start,cpp"
# export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"
export DISTCC_SSH="${OPENSHIFT_DATA_DIR}/bin/distcc-ssh"
tmp_string=$(echo ${DISTCC_HOSTS} | sed -e "s|/2:|/1:|g")
tmp_string=$(echo ${tmp_string} | sed -e "s|,cpp||g")
export DISTCC_HOSTS="${tmp_string}"
# export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"

php_version=5.6.9
cd /tmp
# rm -f php-${php_version}.tar.xz
rm -rf php-${php_version}
# wget http://jp1.php.net/get/php-${php_version}.tar.xz/from/this/mirror -O php-${php_version}.tar.xz
tar Jxf php-${php_version}.tar.xz
cd php-${php_version}
echo $(date)

echo "***** configure *****" >> /tmp/distcc.log

./configure \
--prefix=${OPENSHIFT_DATA_DIR}/php \
--mandir=${OPENSHIFT_TMP_DIR}/man \
--docdir=${OPENSHIFT_TMP_DIR}/doc \
--with-apxs2=${OPENSHIFT_DATA_DIR}/apache/bin/apxs \
--with-mysql \
--with-pdo-mysql \
--without-sqlite3 \
--without-pdo-sqlite \
--without-pear \
--with-curl \
--with-libdir=lib64 \
--with-bz2 \
--with-iconv \
--with-openssl \
--with-zlib \
--with-gd \
--enable-exif \
--enable-ftp \
--enable-xml \
--enable-mbstring \
--enable-mbregex \
--enable-sockets \
--disable-ipv6 \
--with-gettext=${OPENSHIFT_DATA_DIR}/php > /dev/null

rm -f /tmp/distcc.log
echo $(date)

oo-cgroup-read memory.failcnt

echo "***** make *****" >> /tmp/distcc.log

# make -j12 > /dev/null
make ${MAKEOPTS} > /dev/null

echo "***** maked *****" >> /tmp/distcc.log

echo $(date)

ps auwx | grep ssh

wc -l /tmp/distcc.log

oo-cgroup-read memory.failcnt
