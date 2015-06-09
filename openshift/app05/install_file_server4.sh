#!/bin/bash

# rhc setup --server openshift.redhat.com --create-token -l mail_address -p password
# rhc app create xxx php-5.4 cron-1.4 --server openshift.redhat.com

# cd /tmp && wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app05/install_file_server4.sh && chmod +x install_file_server4.sh && ./install_file_server4.sh | tee ${OPENSHIFT_LOG_DIR}/install.log

set -x

export TZ=JST-9

# ***** args *****

if [ $# -ne 3 ]; then
    echo "arg1 : build password"
    echo "arg2 : openshift account"
    echo "arg3 : openshift password"
    exit
fi

build_password=${1}
openshift_account=${2}
openshift_password=${3}

mkdir ${OPENSHIFT_DATA_DIR}/files
pushd ${OPENSHIFT_REPO_DIR} > /dev/null
ln -s ${OPENSHIFT_DATA_DIR}/files files
popd > /dev/null

# distcc_version 3.1
# ccache_version 3.2.2
# openssh_version 6.8p1 → 6.3p1
# tcl_version 8.6.3
# expect_version 5.45
# xz_version 5.2.1

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

# ***** distcc *****

distcc_version=3.1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2
tar jxf distcc-${distcc_version}.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/distcc \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null
rm -rf ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version}
rm -f distcc-${distcc_version}.tar.bz2

mkdir ${OPENSHIFT_DATA_DIR}.distcc

# ***** ccache *****

ccache_version=3.2.2

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -f ccache-${ccache_version}.tar.xz
wget http://samba.org/ftp/ccache/ccache-${ccache_version}.tar.xz
tar Jxf ccache-${ccache_version}.tar.xz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/ccache-${ccache_version} > /dev/null
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/ccache \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc
make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null
rm -rf ${OPENSHIFT_TMP_DIR}/ccache-${ccache_version}
rm -f ccache-${ccache_version}.tar.xz

# ***** openssh *****

# openssh_version=6.8p1
openssh_version=6.3p1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/openssh-${openssh_version}.tar.gz
wget http://www.psc.edu/index.php/hpn-ssh-patches/hpn-14-kitchen-sink-patches/finish/24-hpn-14-kitchen-sink-patches/102-openssh-6-3p1-hpnssh14v2-kitchen-sink-patch \
 -O openssh-6.3p1-hpnssh14v2.diff.gz
tar zxf openssh-${openssh_version}.tar.gz
gzip -d openssh-6.3p1-hpnssh14v2.diff.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/openssh-${openssh_version} > /dev/null
patch < ../openssh-6.3p1-hpnssh14v2.diff
# ./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/openssh \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --disable-etc-default-login \
 --disable-utmp \
 --disable-utmpx \
 --disable-wtmp \
 --disable-wtmpx \
 --with-lastlog=${OPENSHIFT_LOG_DIR}/ssh_lastlog.log
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

mkdir ${OPENSHIFT_DATA_DIR}/.ssh
mkdir ${OPENSHIFT_TMP_DIR}/.ssh
pushd ${OPENSHIFT_DATA_DIR}/.ssh > /dev/null
cat << __HEREDOC__ > config
Host *
  IdentityFile __OPENSHIFT_DATA_DIR__.ssh/id_rsa
  StrictHostKeyChecking no
#  BatchMode yes
  UserKnownHostsFile /dev/null
  LogLevel QUIET
#  LogLevel DEBUG3
  Protocol 2
  Ciphers arcfour256,arcfour128
  AddressFamily inet
#  PreferredAuthentications publickey,gssapi-with-mic,hostbased,keyboard-interactive,password
  PreferredAuthentications publickey
  PasswordAuthentication no
  # Unsupported option "gssapiauthentication"
#  GSSAPIAuthentication no
  ConnectionAttempts 5
  ControlMaster auto
  # ControlPath too long
#  ControlPath __OPENSHIFT_DATA_DIR__.ssh/master-%r@%h:%p
  ControlPath __OPENSHIFT_TMP_DIR__.ssh/master-%r@%h:%p
  ControlPersist 30m
  ServerAliveInterval 60
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" config
sed -i -e "s|__OPENSHIFT_TMP_DIR__|${OPENSHIFT_TMP_DIR}|g" config
popd > /dev/null

# *** distcc-ssh ***

mkdir ${OPENSHIFT_DATA_DIR}/bin
pushd ${OPENSHIFT_DATA_DIR}/bin > /dev/null
cat << '__HEREDOC__' > distcc-ssh
#!/bin/bash

export TZ=JST-9
export HOME=${OPENSHIFT_DATA_DIR}
echo "$(date +%Y/%m/%d" "%H:%M:%S) $@" >> ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
exec ${OPENSHIFT_DATA_DIR}/openssh/bin/ssh -F ${OPENSHIFT_DATA_DIR}/.ssh/config $@
__HEREDOC__
chmod +x distcc-ssh
popd > /dev/null

rm -rf openssh-${openssh_version}
rm -f openssh-${openssh_version}.tar.gz
rm -f openssh-*.diff.gz

# ***** xz *****

xz_version=5.2.1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -f xz-${xz_version}.tar.xz
rm -rf xz-${xz_version}
wget http://tukaani.org/xz/xz-${xz_version}.tar.xz
tar Jxf xz-${xz_version}.tar.xz
pushd  xz-${xz_version} > /dev/null
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/xz \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --disable-doc

time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null
rm -rf xz-${xz_version}
rm -f xz-${xz_version}.tar.xz
popd > /dev/null

# ***** Tcl *****

tcl_version=8.6.3

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://prdownloads.sourceforge.net/tcl/tcl${tcl_version}-src.tar.gz
tar zxf tcl${tcl_version}-src.tar.gz
pushd ${OPENSHIFT_TMP_DIR}/tcl${tcl_version}/unix > /dev/null
./configure --help
./configure \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --disable-symbols \
 --prefix=${OPENSHIFT_DATA_DIR}/tcl
time make -j2 -l3
make install
popd > /dev/null
rm -rf tcl${tcl_version}
rm -f tcl${tcl_version}-src.tar.gz
popd > /dev/null

# ***** Expect *****

expect_version=5.45

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://downloads.sourceforge.net/project/expect/Expect/${expect_version}/expect${expect_version}.tar.gz
tar zxf expect${expect_version}.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/expect${expect_version} > /dev/null
./configure \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --prefix=${OPENSHIFT_DATA_DIR}/expect
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

# ***** rhc *****

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
# gem environment
gem install commander -v 4.2.1 --no-rdoc --no-ri
gem install rhc --no-rdoc --no-ri

${OPENSHIFT_DATA_DIR}.gem/bin/rhc --help

echo set timeout 60 > ${OPENSHIFT_TMP_DIR}/rhc_setup.txt
echo spawn ${OPENSHIFT_DATA_DIR}.gem/bin/rhc setup --server openshift.redhat.com \
 --create-token -l ${openshift_account} -p ${openshift_password} >> ${OPENSHIFT_TMP_DIR}/rhc_setup.txt

cat << '__HEREDOC__' >> ${OPENSHIFT_TMP_DIR}/rhc_setup.txt
expect "(yes|no)"
send "yes\r"
expect "(yes|no)"
send "yes\r"
expect "Provide a name for this key"
send "\r"
interact
__HEREDOC__

env_home_backup=${HOME}
export HOME=${OPENSHIFT_DATA_DIR}
${OPENSHIFT_DATA_DIR}/tcl/bin/expect -f ${OPENSHIFT_TMP_DIR}/rhc_setup.txt

pushd  ${OPENSHIFT_TMP_DIR} > /dev/null
rhc apps | grep -e SSH | grep -v -e ${OPENSHIFT_APP_UUID} | awk '{print $2}' > ${OPENSHIFT_DATA_DIR}/user_fqdn.txt
while read LINE
do
    user_fqdn=$(echo "${LINE}")
    ${OPENSHIFT_DATA_DIR}/openssh/bin/ssh -fMN -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn}
    user_string=$(echo "${LINE}" | awk -F@ '{print $1}')
    distcc_hosts_string="${distcc_hosts_string} ${user_fqdn}/4:/var/lib/openshift/${user_string}/app-root/data/distcc/bin/distccd_start"
done < ${OPENSHIFT_DATA_DIR}/user_fqdn.txt
popd > /dev/null
distcc_hosts_string="${distcc_hosts_string:1}"
echo "${distcc_hosts_string}" > ${OPENSHIFT_DATA_DIR}/distcc_hosts.txt
export HOME=${env_home_backup}

# ***** build action *****

pushd  ${OPENSHIFT_DATA_DIR}/files/ > /dev/null

: << '__COMMENT__'
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <passsword value="" />
  <uuid value="" />
  <data_dir value="" />
  <tmp_dir value="" />
  <items>
    <item app="" version="" />
  </items>
</root>
__COMMENT__

cat << '__HEREDOC__' > build_action.php
<?php
$file_name = getenv('OPENSHIFT_DATA_DIR') . 'version_list';
$xml_data = file_get_contents('php://input');
$xml = simplexml_load_string($xml_data);
$password = $xml->passsword['value'];
if ( $password != '__BUILD_PASSWORD__' )
{
    die;
}
$uuid = $xml->uuid['value'];
$data_dir = $xml->data_dir['value'];
$tmp_dir = $xml->tmp_dir['value'];
unlink($file_name);
foreach($xml->items->item as $item)
{
    file_put_contents($file_name, $item['app'] . '_version ' . $item['version'] . "\n", FILE_APPEND);
}
file_put_contents(getenv('OPENSHIFT_DATA_DIR') . 'build_action_params', $uuid . ' ' . $data_dir . ' ' . $tmp_dir);
?>
__HEREDOC__
sed -i -e "s|__BUILD_PASSWORD__|${build_password}|g" build_action.php
popd > /dev/null

pushd  ${OPENSHIFT_DATA_DIR} > /dev/null
wget --no-cache https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app05/build_action2.sh
popd > /dev/null

# ***** cron minutely *****

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null
rm -f ./*
touch jobs.deny

# *** index.html ***

cat << '__HEREDOC__' > make_index.sh
#!/bin/bash

export TZ=JST-9

pushd ${OPENSHIFT_DATA_DIR}/files > /dev/null
echo "<HTML><BODY><PRE>" > ${OPENSHIFT_TMP_DIR}/index.html
ls -lang >> ${OPENSHIFT_TMP_DIR}/index.html
echo "</PRE></BODY></HTML>" >> ${OPENSHIFT_TMP_DIR}/index.html
mv -f ${OPENSHIFT_TMP_DIR}/index.html ./
popd > /dev/null

pushd ${OPENSHIFT_LOG_DIR} > /dev/null
echo "<HTML><BODY><PRE>" > ${OPENSHIFT_TMP_DIR}/index.html
ls -lang >> ${OPENSHIFT_TMP_DIR}/index.html
echo "</PRE></BODY></HTML>" >> ${OPENSHIFT_TMP_DIR}/index.html
mv -f ${OPENSHIFT_TMP_DIR}/index.html ./
popd > /dev/null
__HEREDOC__
chmod +x make_index.sh
echo make_index.sh >> jobs.allow

# *** build action ***

cat << '__HEREDOC__' > build_action_start.sh
#!/bin/bash

export TZ=JST-9

[ ! -f ${OPENSHIFT_DATA_DIR}/build_action_params ] && exit

set -x

echo 'build start'
ymdhms=$(date +%Y%m%d%H%M%S)

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
rm -f build_action2.sh
wget --no-cache https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app05/build_action2.sh
popd > /dev/null
params=$(cat ${OPENSHIFT_DATA_DIR}/build_action_params)
echo "${params}"
nohup bash ${OPENSHIFT_DATA_DIR}/build_action2.sh ${params} \
 >> ${OPENSHIFT_LOG_DIR}/nohup.${ymdhms}.log \
 2>> ${OPENSHIFT_LOG_DIR}/nohup_error.${ymdhms}.log &

rm -f ${OPENSHIFT_DATA_DIR}/build_action_params
__HEREDOC__
chmod +x build_action_start.sh
echo build_action_start.sh >> jobs.allow

popd > /dev/null

# ***** cron hourly *****

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/hourly > /dev/null
rm -f ./*
touch jobs.deny

# *** rm build files ***

cat << '__HEREDOC__' > rm_build_files.sh
#!/bin/bash

export TZ=JST-9

find ${OPENSHIFT_DATA_DIR}/files/ -name '*_maked_*' -type f -mmin +600 -print0
find ${OPENSHIFT_DATA_DIR}/files/ -name '*_maked_*' -type f -mmin +600 -print0 | xargs -0i rm -f {}
find ${OPENSHIFT_LOG_DIR} -name 'nohup*' -type f -mmin +600 -print0
find ${OPENSHIFT_LOG_DIR} -name 'nohup*' -type f -mmin +600 -print0 | xargs -0i rm -f {}
find ${OPENSHIFT_TMP_DIR} -name 'ruby-build.*' -type f -mmin +600 -print0
find ${OPENSHIFT_TMP_DIR} -name 'ruby-build.*' -type f -mmin +600 -print0 | xargs -0i rm -f {}
__HEREDOC__
chmod +x rm_build_files.sh
echo rm_build_files.sh >> jobs.allow

popd > /dev/null

# ***** cron daily *****

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/daily > /dev/null
rm -f ./*
touch jobs.deny

# *** quota ***

cat << '__HEREDOC__' > quota_info.sh
#!/bin/bash

export TZ=JST-9
pushd ${OPENSHIFT_LOG_DIR} > /dev/null
quota -s > quota.txt
popd > /dev/null
__HEREDOC__
chmod +x quota_info.sh
echo quota_info.sh >> jobs.allow
./quota_info.sh

# *** gem ***

cat << '__HEREDOC__' > gem.sh
#!/bin/bash

export TZ=JST-9
pushd ${OPENSHIFT_DATA_DIR}/files/ > /dev/null

for gem in bundler rack passenger logglier
do
    rm -f ${gem}.html
    # --no-check-certificate
    wget --no-cache https://rubygems.org/gems/${gem} -O ${gem}.html
    version=$(grep -e canonical ${gem}.html | sed -r -e 's|^.*versions/(.+)".*$|\1|g')
    if [ ! -f ${gem}-${version}.gem ]; then
        wget https://rubygems.org/downloads/${gem}-${version}.gem -O ${gem}-${version}.gem
        perl -pi -e 's/(\r|\n)//g' ${gem}.html
        perl -pi -e 's/.*gem__sha"> +//g' ${gem}.html
        perl -pi -e 's/ +<.*//g' ${gem}.html
        gem_sha256=$(cat ${gem}.html)
        file_sha256=$(sha256sum ${gem}-${version}.gem | cut -d ' ' -f 1)
        if [ "${gem_sha256}" != "${file_sha256}" ]; then
            rm ${gem}-${version}.gem
        fi
    fi
    rm -f ${gem}.html
done
popd > /dev/null
__HEREDOC__
chmod +x gem.sh
echo gem.sh >> jobs.allow
./gem.sh &

# *** download_file_list ***
# https://github.com/tshr20140816/files/raw/master/openshift/app05/download_file_list.txt

cat << '__HEREDOC__' > download_file_list.sh
#!/bin/bash

export TZ=JST-9
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -f download_file_list.txt
wget --no-cache https://github.com/tshr20140816/files/raw/master/openshift/app05/download_file_list.txt
while read LINE
do
    file_name=$(echo "${LINE}" | awk '{print $1}')
    if [ ! -f ${OPENSHIFT_DATA_DIR}/files/${file_name} ]; then
        url=$(echo "${LINE}" | awk '{print $2}')
        rm -f ${file_name}
        wget ${url} -O ${file_name}
        mv -f ${file_name} ${OPENSHIFT_DATA_DIR}/files/
    fi
done < download_file_list.txt
popd > /dev/null
__HEREDOC__
chmod +x download_file_list.sh
echo download_file_list.sh >> jobs.allow
./download_file_list.sh

popd > /dev/null

wait

# ***** log dir digest auth *****

pushd ${OPENSHIFT_LOG_DIR} > /dev/null

echo user:realm:$(echo -n user:realm:${OPENSHIFT_APP_NAME} | md5sum | cut -c 1-32) > ${OPENSHIFT_DATA_DIR}/.htpasswd
echo AuthType Digest > .htaccess
echo AuthUserFile ${OPENSHIFT_DATA_DIR}/.htpasswd >> .htaccess

cat << '__HEREDOC__' >> .htaccess
AuthName realm

require valid-user

<Files ~ "^.(htpasswd|htaccess)$">
    deny from all
</Files>

AddType "text/plain; charset=UTF-8" .log

# IndexOptions +FancyIndexing

# Force https
RewriteEngine on
RewriteCond %{HTTP:X-Forwarded-Proto} !https
RewriteRule .* https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
__HEREDOC__
popd > /dev/null

pushd ${OPENSHIFT_REPO_DIR} > /dev/null
ln -s ${OPENSHIFT_LOG_DIR} logs
popd > /dev/null

# /usr/bin/gear stop
# /usr/bin/gear start
