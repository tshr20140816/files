#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log
# 1659

set -x

rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log.*
rm -f ${OPENSHIFT_LOG_DIR}/ccache.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
rm -f ${OPENSHIFT_TMP_DIR}/cc*.s

rm -f  ${OPENSHIFT_DATA_DIR}/.distcc/lock/backoff*

cd /tmp

[ -f gcc-4.6.4.tar.gz ] || wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.6.4/gcc-4.6.4.tar.gz
tar ztvf gcc-4.6.4.tar.gz | wc -l

[ -f gcc-core-4.6.4.tar.bz2 ] || wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.6.4/gcc-core-4.6.4.tar.bz2
tar ztvf gcc-core-4.6.4.tar.bz2 | wc -l

# ***** Tcl *****

tcl_version=8.6.3

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
[ -f tcl${tcl_version}-src.tar.gz ] || wget http://prdownloads.sourceforge.net/tcl/tcl${tcl_version}-src.tar.gz
rm -rf tcl${tcl_version}
tar zxf tcl${tcl_version}-src.tar.gz
pushd ${OPENSHIFT_TMP_DIR}/tcl${tcl_version}/unix > /dev/null
./configure --help
./configure \
--mandir=${OPENSHIFT_TMP_DIR}/man \
 --disable-symbols \
 --prefix=${OPENSHIFT_DATA_DIR}/tcl > /dev/null
time make -j2 -l3 > /dev/null
make install > /dev/null
popd > /dev/null
# rm -rf tcl${tcl_version}
# rm -f tcl${tcl_version}-src.tar.gz
popd > /dev/null

tree ${OPENSHIFT_TMP_DIR}/tcl

# ***** Expect *****

expect_version=5.45

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
[ -f expect${expect_version}.tar.gz ] || wget http://downloads.sourceforge.net/project/expect/Expect/${expect_version}/expect${expect_version}.tar.gz
rm -rf expect${expect_version}
tar zxf expect${expect_version}.tar.gz
pushd ${OPENSHIFT_TMP_DIR}/expect${expect_version} > /dev/null
./configure --help
./configure \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --prefix=${OPENSHIFT_DATA_DIR}/tcl \
 --with-tcl=${OPENSHIFT_TMP_DIR}/tcl${tcl_version}/unix > /dev/null
time make -j$(grep -c -e processor /proc/cpuinfo) > /dev/null
make install
rm -rf expect${expect_version}
# rm -f expect${expect_version}.tar.gz
popd > /dev/null
popd > /dev/null

rm -rf ${OPENSHIFT_TMP_DIR}/tcl${tcl_version}

strip -s ${OPENSHIFT_DATA_DIR}/tcl/bin/expect
${OPENSHIFT_DATA_DIR}/tcl/bin/expect -v

exit

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

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"

cd ${OPENSHIFT_DATA_DIR}/ccache/bin 
ln -s ccache cc
ln -s ccache gcc

export CCACHE_PREFIX=distcc
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
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

ccache -s
ccache --zero-stats
ccache --print-config

cd /tmp

find / -name libphp5.so -print 2>/dev/null

cd ${OPENSHIFT_DATA_DIR}/ccache/bin 
unlink cc
unlink gcc

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

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

mirror_server="https://files3-20150207.rhcloud.com/files/"

if [ ${build_server_password} != 'none' ]; then
    wget --post-file=build_request.xml ${mirror_server}build_action.php -O -
fi
popd > /dev/null

cd /tmp
