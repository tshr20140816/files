#!/bin/bash

set -x

# History
# 2016.03.10 fio_version 2.6 → 2.7
# 2016.03.04 php_version 5.6.18 → 5.6.19
# 2016.02.29 baikal_version 0.2.7 → 0.3.5
# 2016.02.26 cacti_version 0.8.8f → 0.8.8g
# 2016.02.05 php_version 5.6.17 → 5.6.18
# 2016.02.04 wordpress_version 4.4.1-ja → 4.4.2-ja
# 2016.01.28 fio_version 2.5 → 2.6
# 2016.01.21 php_version 5.6.16 → 5.6.17
# 2016.01.21 wordpress_version 4.4-ja → 4.4.1-ja
# 2016.01.21 fio_version 2.2.13 → 2.5
# 2016.01.06 wordpress_version 4.3-ja → 4.4-ja
# 2016.01.06 ruby_version 2.1.7 → 2.1.8
# 2015.12.15 fio_version 2.2.12 → 2.2.13
# 2015.12.07 redmine_version 2.6.8 → 2.6.9
# 2015.11.27 php_version 5.6.15 → 5.6.16
# 2015.11.25 fio_version 2.2.11 → 2.2.12
# 2015.11.24 memcached_version 1.4.24 → 1.4.25
# 2015.11.16 redmine_version 2.6.7 → 2.6.8
# 2015.11.06 fio_version 2.2.10 → 2.2.11
# 2015.10.30 php_version 5.6.14 → 5.6.15
# 2015.10.30 redmine_version 2.6.6 → 2.6.7
# 2015.10.30 php_version 5.6.13 → 5.6.14
# 2015.10.09 ccache_version 3.2.3 → 3.2.4
# 2015.09.12 fio_version 2.2.9 → 2.2.10
# 2015.09.10 sphinx_version 2.2.9 → 2.2.10
# 2015.09.05 php_version 5.6.12 → 5.6.13
# 2015.08.20 wordpress_version 4.2.4-ja → 4.3-ja
# 2015.08.19 tcl_version 8.6.3 → 8.6.4
# 2015.08.19 ruby_version 2.1.6 → 2.1.7
# 2015.08.17 ccache_version 3.2.2 → 3.2.3
# 2015.08.07 php_version 5.6.11 → 5.6.12
# 2015.08.06 wordpress_version 4.2.3-ja → 4.2.4-ja
# 2015.08.05 apache_version 2.2.29 → 2.2.31
# 2015.07.28 wordpress_version 4.2.2-ja → 4.2.3-ja
# 2015.07.20 cacti_version 0.8.8e → 0.8.8f
# 2015.07.13 cacti_version 0.8.8d → 0.8.8e
# 2015.07.11 php_version 5.6.10 → 5.6.11
# 2015.07.08 redmine_version 2.6.5 → 2.6.6
# 2015.06.26 fio_version 2.2.8 → 2.2.9
# 2015.06.13 cacti_version 0.8.8c → 0.8.8d
# 2015.06.12 php_version 5.6.9 → 5.6.10
# 2015.05.16 memcached_version 1.4.22 → 1.4.24
# 2015.05.15 php_version 5.6.8 → 5.6.9
# 2015.05.10 ccache_version 3.2.1 → 3.2.2
# 2015.05.10 redmine_version 2.6.4 → 2.6.5
# 2015.05.08 fio_version 2.2.7 → 2.2.8
# 2015.05.08 wordpress_version 4.2.1-ja → 4.2.2-ja
# 2015.04.29 wordpress_version 4.2-ja → 4.2.1-ja
# 2015.04.27 redmine_version 2.6.3 → 2.6.4
# 2015.04.24 wordpress_version 4.1.2-ja → 4.2-ja
# 2015.04.22 wordpress_version 4.1.1-ja → 4.1.2-ja
# 2015.04.17 fio_version 2.2.5 → 2.2.7
# 2015.04.17 php_version 5.6.7 → 5.6.8
# 2015.04.14 ruby_version 2.1.5 → 2.1.6
# 2015.03.23 caldavzap_version 0.12.0 → 0.12.1
# 2015.03.22 php_version 5.6.6 → 5.6.7
# 2015.03.17 redmine_version 2.6.2 → 2.6.3
# 2015.02.20 php_version 5.6.5 → 5.6.6
# 2015.02.20 redmine_version 2.5.3 → 2.6.2
# 2015.02.20 wordpress_version 4.1-ja → 4.1.1-ja
# 2015.02.11 tcl_version 8.6.2 → 8.6.3
# 2015.01.23 php_version 5.6.4 → 5.6.5
# 2015.01.19 ttrss_version 1.15.2 → 1.15.3
# 2015.01.19 memcached_version 1.4.20 → 1.4.22
# 2015.01.09 wordpress_version 4.0-ja → 4.1-ja
# 2014.12.19 php_version 5.6.3 → 5.6.4
# 2014.12.10 ttrss_version 1.15 → 1.15.2
# 2014.12.09 cacti_version 0.8.8b → 0.8.8c
# 2014.12.09 ttrss_version 1.14 → 1.15
# 2014.11.15 ruby_version 2.1.4 → 2.1.5
# 2014.11.15 php_version 5.6.2 → 5.6.3
# 2014.11.12 delegate_version 9.9.12 → 9.9.13
# 2014.10.28 ruby_version 2.1.3 → 2.1.4
# 2014.10.22 ttrss_version 1.13 → 1.14
# 2014.10.22 redmine_version 2.5.2 → 2.5.3
# 2014.10.17 php_version 5.6.1 → 5.6.2
# 2014.10.08 delegate_version 9.9.11 → 9.9.12
# 2014.10.06 php_version 5.6.0 → 5.6.1
# 2014.09.29 ruby_version 2.1.2 → 2.1.3
# 2014.09.23 first

cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/version_list
apcu_version 4.0.10
apache_version 2.2.31
axel_version 2.4
baikal_version 0.3.5
cacti_version 0.8.8g
cadaver_version 0.23.3
caldavzap_version 0.12.1
ccache_version 3.2.4
distcc_version 3.1
delegate_version 9.9.13
expect_version 5.45
fio_version 2.7
ipafont_version 00303
jpegoptim_version 1.4.3
libmemcached_version 1.0.18
memcached_php_ext_version 2.2.0
memcached_version 1.4.25
mrtg_version 2.17.4
murlin_version 0.2.4
openssh_version 6.8p1
optipng_version 0.7.5
php_version 5.6.19
phpicalendar_version 2.4_20100615
redmine_version 2.6.9
ruby_version 2.1.8
sphinx_version 2.2.10
tcl_version 8.6.4
webalizer_version 2.23-08
wordpress_version 4.4.2-ja
xz_version 5.2.1
yuicompressor_version 2.4.8
__HEREDOC__

# pigz_version 2.3.3
# logrotate_version 3.8.8
# nginx_version 1.6.2
# pcre_version 8.36
# xymon_version 4.3.18
# fping_version 3.10
# unix_bench_version 5.1.3
# sysbench_version 0.4.12.5
# c-ares_version 1.10.0
# lynx_version 2.8.7

export TZ=JST-9

mkdir ${OPENSHIFT_DATA_DIR}/install_check_point

pushd ${OPENSHIFT_DATA_DIR}/install_check_point > /dev/null
if [ -f "$(basename "${0}").ok" ]; then
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Skip $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    exit
fi
popd > /dev/null

while read LINE
do
    product=$(echo "${LINE}" | awk '{print $1}')
    version=$(echo "${LINE}" | awk '{print $2}')
    eval "${product}"="${version}"
done < ${OPENSHIFT_DATA_DIR}/version_list

# ***** args *****

if [ $# -ne 22 ]; then
    set +x
    echo "arg1 : redmine email address"
    echo "arg2 : redmine email password"
    echo "arg3 : openshift email address"
    echo "arg4 : openshift email password"
    echo "arg5 : delegate email account (mailaccount/none)"
    # echo "arg6 : delegate email password"
    echo "arg7 : delegate pop server"
    echo "arg8 : another server check (yes/no)"
    echo "arg9 : web beacon server https://xxx/"
    echo "arg10 : web beacon server user (digest auth)"
    echo "arg11 : files download mirror/build server (http://xxx/files/ / none)"
    echo "arg12 : build server password (password / none)"
    echo "arg13 : schedule server (fqdn)"
    echo "arg14 : distcc server account 1"
    echo "arg15 : distcc server password 1"
    echo "arg16 : distcc server account 2"
    echo "arg17 : distcc server password 2"
    echo "arg18 : hidrive account"
    echo "arg19 : hidrive password"
    echo "arg20 : loggly token"
    echo "arg21 : build server 2 (http://xxx/files/ / none)"
    echo "arg22 : user default password (redmine)"
    exit
fi

redmine_email_address=${1}
redmine_email_password=${2}
openshift_email_address=${3}
openshift_email_password=${4}
delegate_email_account=${5}
# delegate_email_password=${6}
delegate_pop_server=${7}
another_server_check=${8}
web_beacon_server=${9}
web_beacon_server_user=${10}
mirror_server=${11}
build_server_password=${12}
schedule_server=${13}
distcc_server_account_1=${14}
distcc_server_password_1=${15}
distcc_server_account_2=${16}
distcc_server_password_2=${17}
hidrive_account=${18}
hidrive_password=${19}
loggly_token=${20}
build_server_2=${21}
user_default_password=${22}

rm -rf ${OPENSHIFT_DATA_DIR}/params
mkdir ${OPENSHIFT_DATA_DIR}/params

echo "${redmine_email_address}" > ${OPENSHIFT_DATA_DIR}/params/redmine_email_address
echo "${redmine_email_password}" > ${OPENSHIFT_DATA_DIR}/params/redmine_email_password
echo "${openshift_email_address}" > ${OPENSHIFT_DATA_DIR}/params/openshift_email_address
echo "${openshift_email_password}" > ${OPENSHIFT_DATA_DIR}/params/openshift_email_password
echo "${delegate_email_account}" > ${OPENSHIFT_DATA_DIR}/params/delegate_email_account
# echo "${delegate_email_password}" > ${OPENSHIFT_DATA_DIR}/params/delegate_email_password
echo "${delegate_pop_server}" > ${OPENSHIFT_DATA_DIR}/params/delegate_pop_server
echo "${another_server_check}" > ${OPENSHIFT_DATA_DIR}/params/another_server_check
echo "${web_beacon_server}" > ${OPENSHIFT_DATA_DIR}/params/web_beacon_server
echo "${web_beacon_server_user}" > ${OPENSHIFT_DATA_DIR}/params/web_beacon_server_user
echo "${mirror_server}" > ${OPENSHIFT_DATA_DIR}/params/mirror_server
echo "${schedule_server}" > ${OPENSHIFT_DATA_DIR}/params/schedule_server
echo "${build_server_password}" > ${OPENSHIFT_DATA_DIR}/params/build_server_password
echo "${distcc_server_account_1}" > ${OPENSHIFT_DATA_DIR}/params/distcc_server_account_1
echo "${distcc_server_password_1}" > ${OPENSHIFT_DATA_DIR}/params/distcc_server_password_1
echo "${distcc_server_account_2}" > ${OPENSHIFT_DATA_DIR}/params/distcc_server_account_2
echo "${distcc_server_password_2}" > ${OPENSHIFT_DATA_DIR}/params/distcc_server_password_2
echo "${hidrive_account}" > ${OPENSHIFT_DATA_DIR}/params/hidrive_account
echo "${hidrive_password}" > ${OPENSHIFT_DATA_DIR}/params/hidrive_password
echo "${loggly_token}" > ${OPENSHIFT_DATA_DIR}/params/loggly_token
echo "${build_server_2}" > ${OPENSHIFT_DATA_DIR}/params/build_server_2
echo "${user_default_password}" > ${OPENSHIFT_DATA_DIR}/params/user_default_password

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Start $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo "$(quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}')" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo "$(oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}')" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo "$(oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}')" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo "$(oo-cgroup-read memory.memsw.failcnt | awk '{printf "Swap Memory Fail Count : %\047d\n", $1}')" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# ***** git *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) github" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

curl -L https://status.github.com/api/status.json | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo | tee -a ${OPENSHIFT_LOG_DIR}/install.log

rm -rf ${OPENSHIFT_DATA_DIR}/github
mkdir ${OPENSHIFT_DATA_DIR}/github
pushd ${OPENSHIFT_DATA_DIR}/github > /dev/null
git init
git remote add origin https://github.com/tshr20140816/files.git
git pull origin master
rm -rf openshift/app02
rm -rf openshift/app03
rm -rf openshift/app04
rm -rf openshift/app05
rm -rf openshift/app06
rm -f openshift/*
popd > /dev/null

# ***** build request *****

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
    <item app="php" version="__PHP_VERSION__" />
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
sed -i -e "s|__PHP_VERSION__|${php_version}|g" build_request.xml
sed -i -e "s|__DELEGATE_VERSION__|${delegate_version}|g" build_request.xml
sed -i -e "s|__TCL_VERSION__|${tcl_version}|g" build_request.xml
sed -i -e "s|__CADAVER_VERSION__|${cadaver_version}|g" build_request.xml

if [ ${build_server_password} != 'none' ]; then
    wget --post-file=build_request.xml ${mirror_server}build_action.php -O -
    if [ ${build_server_2} != 'none' ]; then
        wget --post-file=build_request.xml ${build_server_2}build_action.php -O -
    fi
fi
popd > /dev/null

# ***** download files *****

rm -f ${OPENSHIFT_LOG_DIR}/install_alert.log
rm -rf ${OPENSHIFT_DATA_DIR}/download_files
mkdir ${OPENSHIFT_DATA_DIR}/download_files
pushd ${OPENSHIFT_DATA_DIR}/download_files > /dev/null

# *** 必要なファイルの事前ダウンロード 成功まで10回繰り返す ***

# * gpg *

export GNUPGHOME=${OPENSHIFT_DATA_DIR}/.gnupg
rm -rf ${GNUPGHOME}
mkdir ${GNUPGHOME}
chmod 700 ${GNUPGHOME}
gpg --list-keys
echo "keyserver hkp://keyserver.ubuntu.com:80" >> ${GNUPGHOME}/gpg.conf
chmod 600 ${GNUPGHOME}/gpg.conf

# * まずミラーサーバよりダウンロード *

if [ "${mirror_server}" != "none" ]; then

    # ccache passenger-install-apache2-module
    wget -t1 ${mirror_server}/ccache_passenger-install-apache2-module.tar.xz &
    # ccache php
    wget -t1 ${mirror_server}/ccache_php.tar.xz &
    # ipa font
    wget -t1 ${mirror_server}/ipagp${ipafont_version}.zip &
    # webalizer
    wget -t1 ${mirror_server}/webalizer-${webalizer_version}-src.tar.bz2 &
    # # ttrss
    # wget -t1 ${mirror_server}/${ttrss_version}.tar.gz &
    # cacti
    wget -t1 ${mirror_server}/cacti-${cacti_version}.tar.gz &
    # tcl
    wget -t1 ${mirror_server}/tcl${tcl_version}-src.tar.gz &
    # expect
    wget -t1 ${mirror_server}/expect${expect_version}.tar.gz &
    # # logrotate
    # wget -t1 ${mirror_server}/logrotate-${logrotate_version}.tar.gz &
    # # lynx
    # wget -t1 ${mirror_server}/lynx${lynx_version}.tar.gz &
    # memcached
    wget -t1 ${mirror_server}/memcached-${memcached_version}.tar.gz &
    # memcached(php extension)
    wget -t1 ${mirror_server}/memcached-${memcached_php_ext_version}.tgz &
    # mURLin
    wget -t1 ${mirror_server}/mURLin-${murlin_version}.tar.gz &
    # fio
    wget -t1 ${mirror_server}/fio-${fio_version}.tar.bz2 &
    # Baikal
    wget -t1 ${mirror_server}/baikal-${baikal_version}.zip &
    # CalDavZAP
    wget -t1 ${mirror_server}/CalDavZAP_${caldavzap_version}.zip &
    # phpicalendar
    wget -t1 ${mirror_server}/phpicalendar-${phpicalendar_version}.tar.bz2 &
    # axel
    wget -t1 ${mirror_server}/axel-${axel_version}.tar.bz2 &
    # sphinx
    wget -t1 ${mirror_server}/sphinx-${sphinx_version}-release.tar.gz &
    # ld.gold
    wget -t1 ${mirror_server}/ld.gold &
    # apcu
    wget -t1 ${mirror_server}/apcu-${apcu_version}.zip &
    # jpegoptim
    wget -t1 ${mirror_server}/jpegoptim-${jpegoptim_version}.tar.gz &
    # optipng
    wget -t1 ${mirror_server}/optipng-${optipng_version}.tar.gz &
    # Yui compressor
    wget -t1 ${mirror_server}/yuicompressor-${yuicompressor_version}.jar &
    wait

    # apache
    wget -t1 ${mirror_server}/httpd-${apache_version}.tar.bz2
    tarball_md5=$(md5sum httpd-${apache_version}.tar.bz2 | cut -d ' ' -f 1)
    apache_md5=$(curl -Ls http://www.apache.org/dist/httpd/httpd-${apache_version}.tar.bz2.md5 | cut -d ' ' -f 1)
    if [ "${tarball_md5}" != "${apache_md5}" ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) apache md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) apache md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm -f httpd-${apache_version}.tar.bz2
    fi

    # libmemcached
    wget -t1 ${mirror_server}/libmemcached-${libmemcached_version}.tar.gz
    tarball_md5=$(md5sum libmemcached-${libmemcached_version}.tar.gz | cut -d ' ' -f 1)
    libmemcached_md5=$(curl -Ls https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz/+md5 | cut -d ' ' -f 1)
    if [ "${tarball_md5}" != "${libmemcached_md5}" ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm -f libmemcached-${libmemcached_version}.tar.gz
    fi

    # mrtg
    wget -t1 ${mirror_server}/mrtg-${mrtg_version}.tar.gz
    tarball_md5=$(md5sum mrtg-${mrtg_version}.tar.gz | cut -d ' ' -f 1)
    mrtg_md5=$(curl -Ls http://oss.oetiker.ch/mrtg/pub/mrtg-${mrtg_version}.tar.gz.md5 | cut -d ' ' -f 1)
    if [ "${tarball_md5}" != "${mrtg_md5}" ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mrtg md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mrtg md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm -f mrtg-${mrtg_version}.tar.gz
    fi

    # php
    wget -t1 ${mirror_server}/php-${php_version}.tar.xz
    wget http://jp2.php.net/distributions/php-${php_version}.tar.xz.asc
    gpg --recv-keys $(gpg --verify php-${php_version}.tar.xz.asc 2>&1 | grep "RSA key ID" | awk '{print $NF}')
    if [ $(gpg --verify php-${php_version}.tar.xz.asc 2>&1 | grep -c "Good signature from") != 1 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) php pgp unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) php pgp unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm -f php-${php_version}.tar.xz
    fi

    # delegate
    # TODO check
    # http://delegate.hpcc.jp/anonftp/DeleGate/verify.sh
    # wget http://delegate.hpcc.jp/anonftp/DeleGate/delegate{delegate_version}.tar.sign
    wget -t1 ${mirror_server}/delegate${delegate_version}.tar.gz

    # redmine
    wget -t1 ${mirror_server}/redmine-${redmine_version}.tar.gz
    tarball_md5=$(md5sum redmine-${redmine_version}.tar.gz | cut -d ' ' -f 1)
    redmine_md5=$(curl -Ls https://www.redmine.org/releases/redmine-${redmine_version}.tar.gz.md5 | cut -d ' ' -f 1)
    if [ "${tarball_md5}" != "${redmine_md5}" ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) redmine md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) redmine md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm -f redmine-${redmine_version}.tar.gz
    fi

    # wordpress
    wget -t1 ${mirror_server}/wordpress-${wordpress_version}.tar.gz
    tarball_md5=$(md5sum wordpress-${wordpress_version}.tar.gz | cut -d ' ' -f 1)
    wordpress_md5=$(curl -Ls https://ja.wordpress.org/wordpress-${wordpress_version}.tar.gz.md5)
    if [ "${tarball_md5}" != "${wordpress_md5}" ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) wordpress md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) wordpress md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm -f wordpress-${wordpress_version}.tar.gz
    fi

    # # nginx
    # wget -t1 ${mirror_server}/nginx-${nginx_version}.tar.gz
    # wget http://nginx.org/download/nginx-${nginx_version}.tar.gz.asc
    # gpg --recv-keys $(gpg --verify nginx-${nginx_version}.tar.gz.asc 2>&1 | grep "RSA key ID" | awk '{print $NF}')
    # if [ $(gpg --verify nginx-${nginx_version}.tar.gz.asc 2>&1 | grep -c "Good signature from") != 1 ]; then
    #     echo $(date +%Y/%m/%d" "%H:%M:%S) nginx pgp unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     echo $(date +%Y/%m/%d" "%H:%M:%S) nginx pgp unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     rm nginx-${nginx_version}.tar.gz
    # fi

    # # pcre
    # wget -t1 ${mirror_server}/pcre-${pcre_version}.tar.bz2
    # wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${pcre_version}.tar.bz2.sig
    # gpg --recv-keys $(gpg --verify pcre-${pcre_version}.tar.bz2.sig 2>&1 | grep "RSA key ID" | awk '{print $NF}')
    # if [ $(gpg --verify pcre-${pcre_version}.tar.bz2.sig 2>&1 | grep -c "Good signature from") != 1 ]; then
    #     echo $(date +%Y/%m/%d" "%H:%M:%S) pcre pgp unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     echo $(date +%Y/%m/%d" "%H:%M:%S) pcre pgp unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     rm pcre-${pcre_version}.tar.bz2
    # fi
    
    # # xymon
    # wget -t1 ${mirror_server}/xymon-${xymon_version}.tar.gz
    
    # # UnixBench
    # wget -t1 ${mirror_server}/UnixBench${unix_bench_version}.tgz
    # tarball_sha1=$(sha1sum UnixBench${unix_bench_version}.tgz | cut -d ' ' -f 1)
    # unix_bench_sha1=$(curl https://code.google.com/p/byte-unixbench/downloads/detail?name=UnixBench${unix_bench_version}.tgz -s \
    # | grep sha1 \
    # | awk '{print substr(substr($0, index($0, "sha1")), 7, 40)}')
    # if [ "${tarball_sha1}" != "${unix_bench_sha1}" ]; then
    #     echo $(date +%Y/%m/%d" "%H:%M:%S) UnixBench sha1 unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     echo $(date +%Y/%m/%d" "%H:%M:%S) UnixBench sha1 unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     rm UnixBench${unix_bench_version}.tgz
    # fi

    # # SysBench
    # wget -t1 ${mirror_server}/sysbench-${sysbench_version}.tar.gz

    # ccache
    wget -t1 ${mirror_server}/ccache-${ccache_version}.tar.xz
    wget https://www.samba.org/ftp/ccache/ccache-${ccache_version}.tar.xz.asc
    gpg --recv-keys $(gpg --verify ccache-${ccache_version}.tar.xz.asc 2>&1 | grep "RSA key ID" | awk '{print $NF}')
    if [ $(gpg --verify ccache-${ccache_version}.tar.xz.asc 2>&1 | grep -c "Good signature from") != 1 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) ccache pgp unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) ccache pgp unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm -f ccache-${ccache_version}.tar.xz
    fi
    rm -f ccache-${ccache_version}.tar.xz.asc

    # # openssh
    # wget -t1 ${mirror_server}/openssh-${openssh_version}.tar.gz
    # wget http://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/openssh-${openssh_version}.tar.gz.asc
    # gpg --recv-keys $(gpg --verify openssh-${openssh_version}.tar.gz.asc 2>&1 | grep "RSA key ID" | awk '{print $NF}')
    # if [ $(gpg --verify openssh-${openssh_version}.tar.gz.asc 2>&1 | grep -c "Good signature from") != 1 ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) openssh pgp unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) openssh pgp unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     rm -f openssh-${openssh_version}.tar.gz
    # fi

    # distcc
    wget -t1 ${mirror_server}/distcc-${distcc_version}.tar.bz2
    wget https://code.google.com/p/distcc/downloads/detail?name=distcc-${distcc_version}.tar.bz2 -O distcc.html
    cat distcc.html | grep sha1 | tee distcc.html
    perl -pi -e 's/<.+?>//g' distcc.html
    perl -pi -e 's/ //g' distcc.html
    distcc_sha1=$(cat distcc.html)
    tarball_sha1=$(sha1sum distcc-${distcc_version}.tar.bz2 | cut -d ' ' -f 1)
    if [ "${distcc_sha1}" != "${tarball_sha1}"]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) distcc-${distcc_version}.tar.bz2 sha1 unmatch" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) distcc-${distcc_version}.tar.bz2 sha1 unmatch" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm -f distcc-${distcc_version}.tar.bz2
    fi
    rm -f distcc.html

    # cadaver
    wget -t1 ${mirror_server}/cadaver-${cadaver_version}.tar.gz
    wget http://www.webdav.org/cadaver/cadaver-${cadaver_version}.tar.gz.asc
    gpg --recv-keys $(gpg --verify cadaver-${cadaver_version}.tar.gz.asc 2>&1 | grep "DSA key ID" | awk '{print $NF}')
    if [ $(gpg --verify cadaver-${cadaver_version}.tar.gz.asc 2>&1 | grep -c "Good signature from") != 1 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver pgp unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver pgp unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm -f cadaver-${cadaver_version}.tar.gz
    fi
    rm -f cadaver-${cadaver_version}.tar.gz.asc

   # xz
   wget -t1 ${mirror_server}/xz-${xz_version}.tar.xz
   wget http://tukaani.org/xz/xz-${xz_version}.tar.xz.sig
   gpg --recv-keys $(gpg --verify xz-${xz_version}.tar.xz.sig 2>&1 | grep "RSA key ID" | awk '{print $NF}')
   if [ $(gpg --verify xz-5.2.1.tar.xz.sig 2>&1 | grep -c "Good signature from") != 1 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) xz pgp unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) xz pgp unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm -f xz-${xz_version}.tar.xz
   fi
   rm -f xz-${xz_version}.tar.xz.sig
    
    # *** gem ***
    for gem in bundler rack passenger logglier
    do
        rm -f ${gem}.html
        wget https://rubygems.org/gems/${gem} -O ${gem}.html
        version=$(grep -e canonical ${gem}.html | sed -r -e 's|^.*versions/(.+)".*$|\1|g')
        if [ ! -f ${gem}-${version}.gem ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) ${gem}-${version}.gem wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            wget -t1 ${mirror_server}/${gem}-${version}.gem -O ${gem}-${version}.gem
            perl -pi -e 's/(\r|\n)//g' ${gem}.html
            perl -pi -e 's/.*gem__sha"> +//g' ${gem}.html
            perl -pi -e 's/ +<.*//g' ${gem}.html
            gem_sha256=$(cat ${gem}.html)
            file_sha256=$(sha256sum ${gem}-${version}.gem | cut -d ' ' -f 1)
            if [ "${gem_sha256}" != "${file_sha256}" ]; then
                echo "$(date +%Y/%m/%d" "%H:%M:%S) ${gem}-${version}.gem sha256 unmatch" \
                 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
                echo "$(date +%Y/%m/%d" "%H:%M:%S) ${gem}-${version}.gem sha256 unmatch" \
                 | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
                rm ${gem}-${version}.gem
            fi
        fi
        rm -f ${gem}.html
    done
fi

files_exists=0
for i in $(seq 0 9)
do
    files_exists=1

    # # *** super pi ***
    # if [ ! -f super_pi-jp.tar.gz ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) super pi wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget ftp://pi.super-computing.org/Linux_jp/super_pi-jp.tar.gz &
    # fi
    # [ -f super_pi-jp.tar.gz ] || files_exists=0

    # *** Closure Compiler ***
    if [ ! -f compiler-latest.zip ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Closure Compiler wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://dl.google.com/closure-compiler/compiler-latest.zip &
    fi
    [ -f compiler-latest.zip ] || files_exists=0

    # *** Tiny Tiny RSS ***
    if [ ! -f ttrss_archive.zip ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) ttrss wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://tt-rss.org/gitlab/fox/tt-rss/repository/archive.zip?ref=master -O ttrss_archive.zip &
    fi
    [ -f ttrss_archive.zip ] || files_exists=0

    # *** YUI Compressor ***
    if [ ! -f yuicompressor-${yuicompressor_version}.jar ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing yuicompressor-${yuicompressor_version}.jar" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) YUI Compressor wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://github.com/yui/yuicompressor/releases/download/v${yuicompressor_version}/yuicompressor-${yuicompressor_version}.jar
    fi

    # *** sphinx ***
    if [ ! -f sphinx-${sphinx_version}-release.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing sphinx-${sphinx_version}-release.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://sphinxsearch.com/files/sphinx-${sphinx_version}-release.tar.gz &
    fi
    [ -f sphinx-${sphinx_version}-release.tar.gz ] || files_exists=0

    # *** jpegoptim ***
    if [ ! -f jpegoptim-${jpegoptim_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing jpegoptim-${jpegoptim_version}.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) jpegoptim wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.kokkonen.net/tjko/src/jpegoptim-${jpegoptim_version}.tar.gz &
    fi
    [ -f jpegoptim-${jpegoptim_version}.tar.gz ] || files_exists=0

    # *** optipng ***
    if [ ! -f optipng-${optipng_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing optipng-${optipng_version}.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) optipng wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://downloads.sourceforge.net/project/optipng/OptiPNG/optipng-${optipng_version}/optipng-${optipng_version}.tar.gz &
    fi
    [ -f optipng-${optipng_version}.tar.gz ] || files_exists=0

    # *** spdy ***
    if [ ! -f mod-spdy-beta_current_x86_64.rpm ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) spdy wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://dl-ssl.google.com/dl/linux/direct/mod-spdy-beta_current_x86_64.rpm &
    fi
    [ -f mod-spdy-beta_current_x86_64.rpm ] || files_exists=0

    # *** rbenv-installer ***
    if [ ! -f rbenv-installer ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) rbenv-installer wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.github.com/Seppone/openshift-rbenv-installer/master/bin/rbenv-installer &
    fi
    [ -f rbenv-installer ] || files_exists=0

    # *** Gemfile_redmine_custom ***
    if [ ! -f Gemfile_redmine_custom ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Gemfile_redmine_custom wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app01/Gemfile_redmine_custom &
    fi
    [ -f Gemfile_redmine_custom ] || files_exists=0

    # *** bash.rb ***
    if [ ! -f bash.rb ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) bash.rb wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app01/bash.rb &
    fi
    [ -f bash.rb ] || files_exists=0

    # *** memcached-tool ***
    if [ ! -f memcached-tool ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached-tool wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/memcached/memcached/master/scripts/memcached-tool &
    fi
    [ -f memcached-tool ] || files_exists=0

    # *** ical_multi ***
    if [ ! -f ical_multi.sh ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) ical_multi.sh wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app01/ical_multi.sh &
    fi
    [ -f ical_multi.sh ] || files_exists=0

    # *** wordpress salt ***
    if [ ! -f salt.txt ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) salt.txt wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        curl -o ./salt.txt https://api.wordpress.org/secret-key/1.1/salt/ &
    fi
    [ -f salt.txt ] || files_exists=0

    # *** apache ***
    if [ ! -f httpd-${apache_version}.tar.bz2 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing httpd-${apache_version}.tar.bz2" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) apache wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://ftp.riken.jp/net/apache//httpd/httpd-${apache_version}.tar.bz2
        tarball_md5=$(md5sum httpd-${apache_version}.tar.bz2 | cut -d ' ' -f 1)
        apache_md5=$(curl -Ls http://www.apache.org/dist/httpd/httpd-${apache_version}.tar.bz2.md5 | cut -d ' ' -f 1)
        if [ "${tarball_md5}" != "${apache_md5}" ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) apache md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            echo "$(date +%Y/%m/%d" "%H:%M:%S) apache md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
            rm httpd-${apache_version}.tar.bz2
        fi
    fi
    [ -f httpd-${apache_version}.tar.bz2 ] || files_exists=0

    # *** redmine ***
    if [ ! -f redmine-${redmine_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing redmine-${redmine_version}.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) redmine wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://www.redmine.org/releases/redmine-${redmine_version}.tar.gz
        tarball_md5=$(md5sum redmine-${redmine_version}.tar.gz | cut -d ' ' -f 1)
        redmine_md5=$(curl -Ls https://www.redmine.org/releases/redmine-${redmine_version}.tar.gz.md5 | cut -d ' ' -f 1)
        if [ "${tarball_md5}" != "${redmine_md5}" ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) redmine md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            echo "$(date +%Y/%m/%d" "%H:%M:%S) redmine md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
            rm redmine-${redmine_version}.tar.gz
        fi
    fi
    [ -f redmine-${redmine_version}.tar.gz ] || files_exists=0

    # *** ipa font ***
    # if [ ! -f IPAfont${ipafont_version}.zip ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) ipa font wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget http://ipafont.ipa.go.jp/ipafont/IPAfont${ipafont_version}.php -O IPAfont${ipafont_version}.zip
    # fi
    # [ -f IPAfont${ipafont_version}.zip ] || files_exists=0
    if [ ! -f ipagp${ipafont_version}.zip ]; then
       echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing ipa font" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
       echo "$(date +%Y/%m/%d" "%H:%M:%S) ipa font wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
       wget http://ipafont.ipa.go.jp/ipafont/ipagp${ipafont_version}.php -O ipagp${ipafont_version}.zip
    fi
    [ -f ipagp${ipafont_version}.zip ] || files_exists=0

    # *** memcached ***
    if [ ! -f memcached-${memcached_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing memcached-${memcached_version}.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.memcached.org/files/memcached-${memcached_version}.tar.gz
    fi
    [ -f memcached-${memcached_version}.tar.gz ] || files_exists=0

    # *** php ***
    if [ ! -f php-${php_version}.tar.xz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing php-${php_version}.tar.xz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) php wget" >> ${OPENSHIFT_LOG_DIR}/install.log
        # wget http://jp1.php.net/get/php-${php_version}.tar.xz/from/this/mirror -O php-${php_version}.tar.xz
        wget http://jp2.php.net/get/php-${php_version}.tar.xz/from/this/mirror -O php-${php_version}.tar.xz
    fi
    [ -f php-${php_version}.tar.xz ] || files_exists=0

    # *** libmemcached ***
    if [ ! -f libmemcached-${libmemcached_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing libmemcached-${libmemcached_version}.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz
        tarball_md5=$(md5sum libmemcached-${libmemcached_version}.tar.gz | cut -d ' ' -f 1)
        libmemcached_md5=$(curl -Ls https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz/+md5 | cut -d ' ' -f 1)
        if [ "${tarball_md5}" != "${libmemcached_md5}" ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            rm libmemcached-${libmemcached_version}.tar.gz
        fi
    fi
    [ -f libmemcached-${libmemcached_version}.tar.gz ] || files_exists=0

    # *** memcached (php extension) ***
    if [ ! -f memcached-${memcached_php_ext_version}.tgz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing memcached-${memcached_php_ext_version}.tgz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached php extension wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://pecl.php.net/get/memcached-${memcached_php_ext_version}.tgz
    fi
    [ -f memcached-${memcached_php_ext_version}.tgz ] || files_exists=0

    # *** delegate ***
    if [ ! -f delegate${delegate_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing delegate${delegate_version}.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) delegate wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.delegate.org/anonftp/DeleGate/delegate${delegate_version}.tar.gz
    fi
    [ -f delegate${delegate_version}.tar.gz ] || files_exists=0

    # *** mrtg ***
    if [ ! -f mrtg-${mrtg_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing mrtg-${mrtg_version}.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mrtg wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://oss.oetiker.ch/mrtg/pub/mrtg-${mrtg_version}.tar.gz
        tarball_md5=$(md5sum mrtg-${mrtg_version}.tar.gz | cut -d ' ' -f 1)
        mrtg_md5=$(curl -Ls http://oss.oetiker.ch/mrtg/pub/mrtg-${mrtg_version}.tar.gz.md5 | cut -d ' ' -f 1)
        if [ "${tarball_md5}" != "${mrtg_md5}" ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) mrtg md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            rm mrtg-${mrtg_version}.tar.gz
        fi
    fi
    [ -f mrtg-${mrtg_version}.tar.gz ] || files_exists=0

    # *** webalizer ***
    if [ ! -f webalizer-${webalizer_version}-src.tar.bz2 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing webalizer-${webalizer_version}-src.tar.bz2" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) webalizer wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget ftp://ftp.mrunix.net/pub/webalizer/webalizer-${webalizer_version}-src.tar.bz2 &
    fi
    [ -f webalizer-${webalizer_version}-src.tar.bz2 ] || files_exists=0

    # *** wordpress ja ***
    if [ ! -f wordpress-${wordpress_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing wordpress-${wordpress_version}.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) wordpress wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://ja.wordpress.org/wordpress-${wordpress_version}.tar.gz &
    fi
    [ -f wordpress-${wordpress_version}.tar.gz ] || files_exists=0

    # *** cacti ***
    if [ ! -f cacti-${cacti_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing cacti-${cacti_version}.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) cacti wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.cacti.net/downloads/cacti-${cacti_version}.tar.gz &
    fi
    [ -f cacti-${cacti_version}.tar.gz ] || files_exists=0

    # # *** cacti patch ***
    # # patch -p1 -N < security.patch
    # if [ ! -f security.patch ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) cacti patch wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget http://www.cacti.net/downloads/patches/${cacti_version}/security.patch
    # fi
    # [ -f security.patch ] || files_exists=0

    # *** mURLin ***
    if [ ! -f mURLin-${murlin_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mURLin wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing mURLin-${murlin_version}.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        wget http://downloads.sourceforge.net/project/murlin/mURLin-${murlin_version}.tar.gz &
    fi
    [ -f mURLin-${murlin_version}.tar.gz ] || files_exists=0

    # *** Tcl ***
    if [ ! -f tcl${tcl_version}-src.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing tcl${tcl_version}-src.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Tcl wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://prdownloads.sourceforge.net/tcl/tcl${tcl_version}-src.tar.gz &
    fi
    [ -f tcl${tcl_version}-src.tar.gz ] || files_exists=0

    # *** Expect ***
    if [ ! -f expect${expect_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing expect${expect_version}.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Expect wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://downloads.sourceforge.net/project/expect/Expect/${expect_version}/expect${expect_version}.tar.gz &
    fi
    [ -f expect${expect_version}.tar.gz ] || files_exists=0

    # # *** nginx ***
    # if [ ! -f nginx-${nginx_version}.tar.gz ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing nginx-${nginx_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) nginx wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget http://nginx.org/download/nginx-${nginx_version}.tar.gz
    # fi
    # [ -f nginx-${nginx_version}.tar.gz ] || files_exists=0

    # # *** pcre ***
    # if [ ! -f pcre-${pcre_version}.tar.bz2 ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing pcre-${pcre_version}.tar.bz2" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) pcre wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${pcre_version}.tar.bz2
    # fi
    # [ -f pcre-${pcre_version}.tar.bz2 ] || files_exists=0

    # # *** xymon ***
    # if [ ! -f xymon-${xymon_version}.tar.gz ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing xymon-${xymon_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) xymon wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget http://downloads.sourceforge.net/project/xymon/Xymon/${xymon_version}/xymon-${xymon_version}.tar.gz
    # fi
    # [ -f xymon-${xymon_version}.tar.gz ] || files_exists=0

    # # *** fping ***
    # if [ ! -f fping-${fping_version}.tar.gz ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) fping wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget http://fping.org/dist/fping-${fping_version}.tar.gz
    # fi
    # [ -f fping-${fping_version}.tar.gz ] || files_exists=0

    # # *** c-ares ***
    # if [ ! -f c-ares-${c-ares_version}.tar.gz ]; then
    #   echo "$(date +%Y/%m/%d" "%H:%M:%S) c-ares wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #   wget http://c-ares.haxx.se/download/c-ares-${c-ares_version}.tar.gz
    # fi
    # [ -f c-ares-${c-ares_version}.tar.gz ] || files_exists=0

    # *** logrotate ***
    # if [ ! -f logrotate-${logrotate_version}.tar.gz ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing logrotate-${logrotate_version}.tar.gz" \
    #      | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) logrotate wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget https://fedorahosted.org/releases/l/o/logrotate/logrotate-${logrotate_version}.tar.gz
    # fi
    # [ -f logrotate-${logrotate_version}.tar.gz ] || files_exists=0

    # # *** Lynx ***
    # if [ ! -f lynx${lynx_version}.tar.gz ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing lynx${lynx_version}.tar.gz" \
    #      | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) Lynx wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget http://lynx.isc.org/lynx${lynx_version}/lynx${lynx_version}.tar.gz &
    # fi
    # [ -f lynx${lynx_version}.tar.gz ] || files_exists=0

    # # *** UnixBench ***
    # if [ ! -f UnixBench${unix_bench_version}.tgz ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing UnixBench${unix_bench_version}.tgz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) UnixBench wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget https://byte-unixbench.googlecode.com/files/UnixBench${unix_bench_version}.tgz
    # fi
    # [ -f UnixBench${unix_bench_version}.tgz ] || files_exists=0

    # # *** SysBench ***
    # if [ ! -f sysbench-${sysbench_version}.tar.gz ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing sysbench-${sysbench_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) SysBench wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget http://downloads.mysql.com/source/sysbench-${sysbench_version}.tar.gz
    # fi
    # [ -f sysbench-${sysbench_version}.tar.gz ] || files_exists=0

    # *** fio ***
    if [ ! -f fio-${fio_version}.tar.bz2 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing fio-${fio_version}.tar.bz2" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) fio wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://brick.kernel.dk/snaps/fio-${fio_version}.tar.bz2 &
    fi
    [ -f fio-${fio_version}.tar.bz2 ] || files_exists=0

    # *** Baikal ***
    if [ ! -f baikal-${baikal_version}.zip ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing baikal-${baikal_version}.zip" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Baikal wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://github.com/fruux/Baikal/releases/download/${baikal_version}/baikal-${baikal_version}.zip &
    fi
    [ -f baikal-${baikal_version}.zip ] || files_exists=0

    # *** CalDavZAP ***
    if [ ! -f CalDavZAP_${caldavzap_version}.zip ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing CalDavZAP_${caldavzap_version}.zip" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) CalDavZAP wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.inf-it.com/CalDavZAP_${caldavzap_version}.zip &
    fi
    [ -f CalDavZAP_${caldavzap_version}.zip ] || files_exists=0

    # *** phpicalendar ***
    if [ ! -f phpicalendar-${phpicalendar_version}.tar.bz2 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing phpicalendar-${phpicalendar_version}.tar.bz2" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) phpicalendar wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://downloads.sourceforge.net/project/phpicalendar/phpicalendar/phpicalendar%202.4%20RC7/phpicalendar-${phpicalendar_version}.tar.bz2 &
    fi
    [ -f phpicalendar-${phpicalendar_version}.tar.bz2 ] || files_exists=0

    # *** axel ***
    if [ ! -f axel-${axel_version}.tar.bz2 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing axel-${axel_version}.tar.bz2" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) axel wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://downloads.sourceforge.net/project/axel2/axel-${axel_version}/axel-${axel_version}.tar.bz2 &
    fi
    [ -f axel-${axel_version}.tar.bz2 ] || files_exists=0

    # *** ccache ***
    if [ ! -f ccache-${ccache_version}.tar.xz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing ccache-${ccache_version}.tar.xz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) ccache wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://samba.org/ftp/ccache/ccache-${ccache_version}.tar.xz &
    fi
    [ -f ccache-${ccache_version}.tar.xz ] || files_exists=0

    # # *** openssh ***
    # if [ ! -f openssh-${openssh_version}.tar.gz ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing openssh-${openssh_version}.tar.gz" \
    #      | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) openssh wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget http://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/openssh-${openssh_version}.tar.gz
    # fi
    # [ -f openssh-${openssh_version}.tar.gz ] || files_exists=0

    # *** distcc ***
    if [ ! -f distcc-${distcc_version}.tar.bz2 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing distcc-${distcc_version}.tar.bz2" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) distcc wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2 &
    fi
    [ -f distcc-${distcc_version}.tar.bz2 ] || files_exists=0

    # *** pigz ***
    # # TODO http://www.zlib.net/pigz/pigz-2.3.3-sig.txt
    # if [ ! -f pigz-${pigz_version}.tar.gz ]; then
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing pigz-${pigz_version}.tar.gz" \
    #      | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     echo "$(date +%Y/%m/%d" "%H:%M:%S) pigz wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget http://www.zlib.net/pigz/pigz-${pigz_version}.tar.gz
    # fi
    # [ -f pigz-${pigz_version}.tar.gz ] || files_exists=0

    # *** GNU Parallel ***
    if [ ! -f parallel-latest.tar.bz2 ]; then
        # TODO http://ftp.gnu.org/gnu/parallel/parallel-latest.tar.bz2.sig
        echo "$(date +%Y/%m/%d" "%H:%M:%S) GNU Parallel wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        # wget http://ftp.gnu.org/gnu/parallel/parallel-latest.tar.bz2
        wget http://ftp.jaist.ac.jp/pub/GNU/parallel/parallel-latest.tar.bz2
    fi
    [ -f parallel-latest.tar.bz2 ] || files_exists=0

    # *** cadaver ***
    if [ ! -f cadaver-${cadaver_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing cadaver-${cadaver_version}.tar.gz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver wget" >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.webdav.org/cadaver/cadaver-${cadaver_version}.tar.gz &
    fi
    [ -f cadaver-${cadaver_version}.tar.gz ] || files_exists=0

    # *** xz ***
    if [ ! -f xz-${xz_version}.tar.xz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing xz-${xz_version}.tar.xz" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) xz wget" >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://tukaani.org/xz/xz-${xz_version}.tar.xz &
    fi
    [ -f xz-${xz_version}.tar.xz ] || files_exists=0

    # *** apcu ***
    if [ ! -f apcu-${apcu_version}.zip ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing apcu-${apcu_version}.zip" \
         | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) apcu wget" >> ${OPENSHIFT_LOG_DIR}/install.log
        wget -O apcu-${apcu_version}.zip https://github.com/krakjoe/apcu/archive/v${apcu_version}.zip &
    fi
    [ -f apcu-${apcu_version}.zip ] || files_exists=0

    # *** gem ***
    for gem in bundler rack passenger logglier
    do
        rm -f ${gem}.html
        wget https://rubygems.org/gems/${gem} -O ${gem}.html
        version=$(grep -e canonical ${gem}.html | sed -r -e 's|^.*versions/(.+)".*$|\1|g')
        if [ ! -f ${gem}-${version}.gem ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing ${gem}-${version}.gem" \
             | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
            echo "$(date +%Y/%m/%d" "%H:%M:%S) ${gem}-${version}.gem wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            wget https://rubygems.org/downloads/${gem}-${version}.gem -O ${gem}-${version}.gem
            perl -pi -e 's/(\r|\n)//g' ${gem}.html
            perl -pi -e 's/.*gem__sha"> +//g' ${gem}.html
            perl -pi -e 's/ +<.*//g' ${gem}.html
            gem_sha256=$(cat ${gem}.html)
            file_sha256=$(sha256sum ${gem}-${version}.gem | cut -d ' ' -f 1)
            if [ "${gem_sha256}" != "${file_sha256}" ]; then
                echo "$(date +%Y/%m/%d" "%H:%M:%S) ${gem}-${version}.gem sha256 unmatch" \
                 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
                echo "$(date +%Y/%m/%d" "%H:%M:%S) ${gem}-${version}.gem sha256 unmatch" \
                 | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
                rm ${gem}-${version}.gem
            fi
        fi
        rm -f ${gem}.html
        [ -f ${gem}-${version}.gem ] || files_exists=0
    done

    wait
    [ "${files_exists}" -eq 1 ] && break
done

popd > /dev/null

if [ ${files_exists} -eq 0 ]; then
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Abort Install miss download files" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    exit
fi

# ***** syntax check *****

pushd ${OPENSHIFT_DATA_DIR}/github/openshift/app01/ > /dev/null

# *** shell ***

for file_name in *.sh
do
    if [ $(/bin/bash -n ${file_name} 2>&1 | wc -l) -gt 0 ]; then
        /bin/bash -n ${file_name} >> ${OPENSHIFT_LOG_DIR}/install_alert.log 2>&1
    fi
done

# *** ruby ***

for file_name in *.rb
do
    if [ "$(ruby -cw ${file_name} 2>&1)" != 'Syntax OK' ]; then
        ruby -cw ${file_name} >> ${OPENSHIFT_LOG_DIR}/install_alert.log 2>&1
    fi
done

popd > /dev/null

# ***** install log *****

touch ${OPENSHIFT_LOG_DIR}/nohup.log
touch ${OPENSHIFT_LOG_DIR}/nohup_error.log
mkdir ${OPENSHIFT_LOG_DIR}/install

# ***** install script *****

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null
rm -f *
touch jobs.deny

install_script_file='install_step_from_02_to_22'
cat << '__HEREDOC__' > install_script_check.sh
#!/bin/bash

if [ -f ${OPENSHIFT_DATA_DIR}/install_check_point/install_all.ok ]; then
    echo "please remove this cron !!! $(basename "${0}")"
    exit
fi

while :
do
    if [ ! -e ${OPENSHIFT_DATA_DIR}/install_check_point/__BASE_NAME__.ok ]; then
        sleep 3s
        continue
    fi
    break
done

# OPENSHIFT_DIY_IP is marker
install_script_file='__INSTALL_SCRIPT_FILE__'
is_alive=$(ps ahwx | grep ${install_script_file} | grep ${OPENSHIFT_DIY_IP} | grep -c -v grep)
if [ ! ${is_alive} -gt 0 ]; then
    export TZ=JST-9
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Retry" | tee -a ${OPENSHIFT_LOG_DIR}/install_retry.log
    cd ${OPENSHIFT_DATA_DIR}/github/openshift/app01
    nohup ./${install_script_file}.sh ${OPENSHIFT_DIY_IP} \
    >> ${OPENSHIFT_LOG_DIR}/nohup.log \
    2>> ${OPENSHIFT_LOG_DIR}/nohup_error.log &
fi
__HEREDOC__
sed -i -e "s|__INSTALL_SCRIPT_FILE__|${install_script_file}|g" install_script_check.sh
sed -i -e "s|__BASE_NAME__|$(basename ${0})|g" install_script_check.sh
chmod 755 install_script_check.sh
echo install_script_check.sh >> jobs.allow

popd > /dev/null

chmod +x ${OPENSHIFT_DATA_DIR}/github/openshift/app01/reboot_agent.sh
${OPENSHIFT_DATA_DIR}/github/openshift/app01/reboot_agent.sh \
 ${install_script_file} \
 ${web_beacon_server} \
 >> ${OPENSHIFT_LOG_DIR}/reboot_agent.log 2>&1 &

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

export TMOUT=0

# gcc --version
# gcc -march=native -Q --help=target

set +x

if [ -f ${OPENSHIFT_LOG_DIR}/install_alert.log ]; then
    echo '***** ALERT *****'
    cat ${OPENSHIFT_LOG_DIR}/install_alert.log
    echo
fi

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null
./install_script_check.sh
popd > /dev/null

echo "tail -f ~/app-root/logs/install.log"

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
