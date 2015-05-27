#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# gcc --help
gcc --version
gcc -march=native -Q --help=target
gcc -march=ivybridge -Q --help=target

cd /tmp

rm -rf ${OPENSHIFT_DATA_DIR}/.gnupg
mkdir ${OPENSHIFT_DATA_DIR}/.gnupg
export GNUPGHOME=${OPENSHIFT_DATA_DIR}/.gnupg
gpg --list-keys
echo "keyserver hkp://keyserver.ubuntu.com:80" >> ${GNUPGHOME}/gpg.conf

cadaver_version=0.23.3

rm -f cadaver-${cadaver_version}.tar.gz
rm -f cadaver-${cadaver_version}.tar.gz.asc
wget http://www.webdav.org/cadaver/cadaver-${cadaver_version}.tar.gz
wget http://www.webdav.org/cadaver/cadaver-${cadaver_version}.tar.gz.asc
gpg --recv-keys $(gpg --verify cadaver-${cadaver_version}.tar.gz.asc 2>&1 | grep "RSA key ID" | awk '{print $NF}')
gpg --verify cadaver-${cadaver_version}.tar.gz.asc 2>&1

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
  Ciphers arcfour
  PasswordAuthentication no
  ConnectionAttempts 5
  ControlMaster auto
  ControlPath /tmp/.ssh/master-%r@%h:%p
  ControlPersist 10s
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" config

# ssh -24n -F config 555781ad4382ece1eb00005e@b4-20150514.rhcloud.com ls -lang app-root/data/distcc/bin

# ssh -24MN -F config 55630afc5973caf283000214@v1-20150216.rhcloud.com &
# ssh -24MN -F config 55630b63e0b8cd7ed000007f@v2-20150216.rhcloud.com &
# ssh -24MN -F config 55630c675973caf283000251@v3-20150216.rhcloud.com &
# ssh -24MN -F config 555894314382ec8df40000e1@b1-20150430.rhcloud.com &
# ssh -24MN -F config 555895235973ca539500007e@b2-20150430.rhcloud.com &
# ssh -24MN -F config 555895dbfcf9337761000009@b3-20150430.rhcloud.com &
# ssh -24MN -F config 555f3483500446724c000127@b7-20150522.rhcloud.com &
# ssh -24MN -F config 555f387de0b8cd419e0000cc@b8-20150522.rhcloud.com &
# ssh -24MN -F config 555f34eae0b8cd8b2400001e@b9-20150522.rhcloud.com &
# ssh -24MN -F config 555781ad4382ece1eb00005e@b4-20150514.rhcloud.com &
# ssh -24MN -F config 555782f44382ecdc6d00003b@b5-20150514.rhcloud.com &
# ssh -24MN -F config 5557844c4382ecd6b00000f8@b6-20150514.rhcloud.com &
# ps auwx | grep ssh

mkdir ${OPENSHIFT_DATA_DIR}/bin 2>/dev/null
pushd ${OPENSHIFT_DATA_DIR}/bin > /dev/null
cat << '__HEREDOC__' > distcc-ssh
#!/bin/bash

echo "$(date +%Y/%m/%d" "%H:%M:%S) $@" >> ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
exec /usr/bin/ssh -24 -F /tmp/.ssh/config $@
__HEREDOC__
chmod +x distcc-ssh
popd > /dev/null

grep -e ERROR ${OPENSHIFT_LOG_DIR}/distcc.log
tail -n 100 ${OPENSHIFT_LOG_DIR}/distcc.log
wc -l ${OPENSHIFT_LOG_DIR}/distcc.log
rm -f /tmp/distcc.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc_ssh.log

rm -f ${OPENSHIFT_DATA_DIR}/.distcc/lock/b*
rm -f ${OPENSHIFT_DATA_DIR}/.distcc/lock/c*

oo-cgroup-read memory.failcnt

echo $(date)

export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
# export DISTCC_LOG=/dev/null
export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc.log
export CC="distcc gcc"
export CXX="distcc g++"
export CFLAGS="-O2 -march=core2 -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"
export MAKEOPTS="-j 12"
export DISTCC_HOSTS="55630afc5973caf283000214@v1-20150216.rhcloud.com/2:/var/lib/openshift/55630afc5973caf283000214/app-root/data/distcc/bin/distccd_start,cpp 55630b63e0b8cd7ed000007f@v2-20150216.rhcloud.com/2:/var/lib/openshift/55630b63e0b8cd7ed000007f/app-root/data/distcc/bin/distccd_start,cpp 55630c675973caf283000251@v3-20150216.rhcloud.com/2:/var/lib/openshift/55630c675973caf283000251/app-root/data/distcc/bin/distccd_start,cpp 555894314382ec8df40000e1@b1-20150430.rhcloud.com/2:/var/lib/openshift/555894314382ec8df40000e1/app-root/data/distcc/bin/distccd_start,cpp 555895235973ca539500007e@b2-20150430.rhcloud.com/2:/var/lib/openshift/555895235973ca539500007e/app-root/data/distcc/bin/distccd_start,cpp 555895dbfcf9337761000009@b3-20150430.rhcloud.com/2:/var/lib/openshift/555895dbfcf9337761000009/app-root/data/distcc/bin/distccd_start,cpp 555f3483500446724c000127@b7-20150522.rhcloud.com/2:/var/lib/openshift/555f3483500446724c000127/app-root/data/distcc/bin/distccd_start,cpp 555f387de0b8cd419e0000cc@b8-20150522.rhcloud.com/2:/var/lib/openshift/555f387de0b8cd419e0000cc/app-root/data/distcc/bin/distccd_start,cpp 555f34eae0b8cd8b2400001e@b9-20150522.rhcloud.com/2:/var/lib/openshift/555f34eae0b8cd8b2400001e/app-root/data/distcc/bin/distccd_start,cpp 555781ad4382ece1eb00005e@b4-20150514.rhcloud.com/2:/var/lib/openshift/555781ad4382ece1eb00005e/app-root/data/distcc/bin/distccd_start,cpp 555782f44382ecdc6d00003b@b5-20150514.rhcloud.com/2:/var/lib/openshift/555782f44382ecdc6d00003b/app-root/data/distcc/bin/distccd_start,cpp 5557844c4382ecd6b00000f8@b6-20150514.rhcloud.com/2:/var/lib/openshift/5557844c4382ecd6b00000f8/app-root/data/distcc/bin/distccd_start,cpp"
# export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"
export DISTCC_SSH="${OPENSHIFT_DATA_DIR}/bin/distcc-ssh"
# tmp_string=$(echo ${DISTCC_HOSTS} | sed -e "s|/2:|/1:|g")
tmp_string=$(echo ${DISTCC_HOSTS} | sed -e "s|,cpp||g")
export DISTCC_HOSTS="${tmp_string}"
# export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"

php_version=5.6.9
apache_version=2.2.29
cd /tmp
rm -f php-${php_version}.tar.xz*
rm -rf php-${php_version}

rm -f httpd-${apache_version}.tar.bz2
rm -rf httpd-${apache_version}

wget http://ftp.riken.jp/net/apache//httpd/httpd-${apache_version}.tar.bz2
tar jxf httpd-${apache_version}.tar.bz2
cd httpd-${apache_version}

echo $(date)

echo "***** configure *****" >> ${OPENSHIFT_LOG_DIR}/distcc.log

./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/apache \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --enable-mods-shared='all proxy' > /dev/null

rm -f ${OPENSHIFT_LOG_DIR}/distcc.log
echo $(date)

oo-cgroup-read memory.failcnt

echo "***** make *****" >> ${OPENSHIFT_LOG_DIR}/distcc.log

# make -j12 > /dev/null
make ${MAKEOPTS} > /dev/null

echo "***** maked *****" >> ${OPENSHIFT_LOG_DIR}/distcc.log

echo $(date)

# ps auwx | grep ssh

# wc -l /tmp/distcc.log

# oo-cgroup-read memory.failcnt
