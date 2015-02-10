#!/bin/bash

set -x

# History
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
# 2014.10.19 del rrdtool
# 2014.10.17 php_version 5.6.1 → 5.6.2
# 2014.10.16 add tcl & expect
# 2014.10.15 add cacti & rrdtool
# 2014.10.08 delegate_version 9.9.11 → 9.9.12
# 2014.10.06 php_version 5.6.0 → 5.6.1
# 2014.09.29 ruby_version 2.1.2 → 2.1.3
# 2014.09.23 first

cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/version_list
apache_version 2.2.29
php_version 5.6.5
delegate_version 9.9.13
mrtg_version 2.17.4
webalizer_version 2.23-08
wordpress_version 4.1-ja
ttrss_version 1.15.3
memcached_version 1.4.22
libmemcached_version 1.0.18
memcached_php_ext_version 2.2.0
ruby_version 2.1.5
redmine_version 2.5.3
ipafont_version 00303
cacti_version 0.8.8c
murlin_version 0.2.4
tcl_version 8.6.2
expect_version 5.45
nginx_version 1.6.2
lynx_version 2.8.7
logrotate_version 3.8.8
pcre_version 8.36
xymon_version 4.3.18
fping_version 3.10
__HEREDOC__

# c-ares_version 1.10.0

# http://httpd.apache.org/
# http://php.net/
# http://delegate.hpcc.jp/delegate/
# https://www.ruby-lang.org/ja/

mkdir ${OPENSHIFT_DATA_DIR}/install_check_point

pushd ${OPENSHIFT_DATA_DIR}/install_check_point > /dev/null
if -f [ `basename $0`.ok ]; then
    echo `date +%Y/%m/%d" "%H:%M:%S` Install Skip `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    exit
fi
popd > /dev/null

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

# ***** args *****

if [ $# -ne 11 ]; then
    set +x
    echo "arg1 : redmine email address"
    echo "arg2 : redmine email password"
    echo "arg3 : openshift email address"
    echo "arg4 : openshift email password"
    echo "arg5 : delegate email account (mailaccount/none)"
    echo "arg6 : delegate email password"
    echo "arg7 : delegate pop server"
    echo "arg8 : another server check (yes/no)"
    echo "arg9 : web beacon server https://xxx/"
    echo "arg10 : web beacon server user (digest auth)"
    echo "arg11 : files download mirror server (http://xxx/files/ / none)"
    exit
fi

redmine_email_address=${1}
redmine_email_password=${2}
openshift_email_address=${3}
openshift_email_password=${4}
delegate_email_account=${5}
delegate_email_password=${6}
delegate_pop_server=${7}
another_server_check=${8}
web_beacon_server=${9}
web_beacon_server_user=${10}
mirror_server=${11}

mkdir ${OPENSHIFT_DATA_DIR}/params

echo ${redmine_email_address} > ${OPENSHIFT_DATA_DIR}/params/redmine_email_address
echo ${redmine_email_password} > ${OPENSHIFT_DATA_DIR}/params/redmine_email_password
echo ${openshift_email_address} > ${OPENSHIFT_DATA_DIR}/params/openshift_email_address
echo ${openshift_email_password} > ${OPENSHIFT_DATA_DIR}/params/openshift_email_password
echo ${delegate_email_account} > ${OPENSHIFT_DATA_DIR}/params/delegate_email_account
echo ${delegate_email_password} > ${OPENSHIFT_DATA_DIR}/params/delegate_email_password
echo ${delegate_pop_server} > ${OPENSHIFT_DATA_DIR}/params/delegate_pop_server
echo ${another_server_check} > ${OPENSHIFT_DATA_DIR}/params/another_server_check
echo ${web_beacon_server} > ${OPENSHIFT_DATA_DIR}/params/web_beacon_server
echo ${web_beacon_server_user} > ${OPENSHIFT_DATA_DIR}/params/web_beacon_server_user

echo ${redmine_email_address} > ${OPENSHIFT_DATA_DIR}/redmine_email_address
echo ${redmine_email_password} > ${OPENSHIFT_DATA_DIR}/redmine_email_password
echo ${openshift_email_address} > ${OPENSHIFT_DATA_DIR}/openshift_email_address
echo ${openshift_email_password} > ${OPENSHIFT_DATA_DIR}/openshift_email_password
echo ${delegate_email_account} > ${OPENSHIFT_DATA_DIR}/delegate_email_account
echo ${delegate_email_password} > ${OPENSHIFT_DATA_DIR}/delegate_email_password
echo ${delegate_pop_server} > ${OPENSHIFT_DATA_DIR}/delegate_pop_server
echo ${another_server_check} > ${OPENSHIFT_DATA_DIR}/another_server_check
echo ${web_beacon_server} > ${OPENSHIFT_DATA_DIR}/web_beacon_server
echo ${web_beacon_server_user} > ${OPENSHIFT_DATA_DIR}/web_beacon_server_user

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 1 Start | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# ***** git *****

echo `date +%Y/%m/%d" "%H:%M:%S` github | tee -a ${OPENSHIFT_LOG_DIR}/install.log

curl -L https://status.github.com/api/status.json | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo | tee -a ${OPENSHIFT_LOG_DIR}/install.log

mkdir ${OPENSHIFT_DATA_DIR}/github
pushd ${OPENSHIFT_DATA_DIR}/github > /dev/null
git init
git remote add origin https://github.com/tshr20140816/files.git
git pull origin master
popd > /dev/null

# ***** download files *****

mkdir ${OPENSHIFT_DATA_DIR}/download_files
pushd ${OPENSHIFT_DATA_DIR}/download_files > /dev/null

rm -f ./*

# *** 必要なファイルの事前ダウンロード 成功まで10回繰り返す ***

# * まずミラーサーバよりダウンロード *

if [ ${mirror_server} != "none" ]; then
    # apache
    wget -t1 ${mirror_server}/httpd-${apache_version}.tar.gz
    tarball_md5=$(md5sum httpd-${apache_version}.tar.gz | cut -d ' ' -f 1)
    apache_md5=$(curl -Ls http://www.apache.org/dist/httpd/httpd-${apache_version}.tar.gz.md5 | cut -d ' ' -f 1)
    if [ "${tarball_md5}" != "${apache_md5}" ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` apache md5 unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo `date +%Y/%m/%d" "%H:%M:%S` apache md5 unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm httpd-${apache_version}.tar.gz
    fi
    # libmemcached
    wget -t1 ${mirror_server}/libmemcached-${libmemcached_version}.tar.gz
    tarball_md5=$(md5sum libmemcached-${libmemcached_version}.tar.gz | cut -d ' ' -f 1)
    libmemcached_md5=$(curl -Ls https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz/+md5 | cut -d ' ' -f 1)
    if [ "${tarball_md5}" != "${libmemcached_md5}" ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached md5 unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached md5 unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm libmemcached-${libmemcached_version}.tar.gz
    fi
    # mrtg
    wget -t1 ${mirror_server}/mrtg-${mrtg_version}.tar.gz
    tarball_md5=$(md5sum mrtg-${mrtg_version}.tar.gz | cut -d ' ' -f 1)
    mrtg_md5=$(curl -Ls http://oss.oetiker.ch/mrtg/pub/mrtg-${mrtg_version}.tar.gz.md5 | cut -d ' ' -f 1)
    if [ "${tarball_md5}" != "${mrtg_md5}" ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mrtg md5 unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo `date +%Y/%m/%d" "%H:%M:%S` mrtg md5 unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm mrtg-${mrtg_version}.tar.gz
    fi
    # ipa font
    wget -t1 ${mirror_server}/ipagp${ipafont_version}.zip
    # php
    wget -t1 ${mirror_server}/php-${php_version}.tar.xz
    # delegate
    wget -t1 ${mirror_server}/delegate${delegate_version}.tar.gz
    # redmine
    wget -t1 ${mirror_server}/redmine-${redmine_version}.tar.gz
    # webalizer
    wget -t1 ${mirror_server}/webalizer-${webalizer_version}-src.tgz
    # wordpress
    wget -t1 ${mirror_server}/wordpress-${wordpress_version}.tar.gz
    # ttrss
    wget -t1 ${mirror_server}/${ttrss_version}.tar.gz
    # cacti
    wget -t1 ${mirror_server}/cacti-${cacti_version}.tar.gz
    # tcl
    wget -t1 ${mirror_server}/tcl${tcl_version}-src.tar.gz
    # expect
    wget -t1 ${mirror_server}/expect${expect_version}.tar.gz
    # logrotate
    wget -t1 ${mirror_server}/logrotate-${logrotate_version}.tar.gz
    # lynx
    wget -t1 ${mirror_server}/lynx${lynx_version}.tar.gz
    # nginx
    wget -t1 ${mirror_server}/nginx-${nginx_version}.tar.gz

    # TODO
fi

files_exists=0
for i in `seq 0 9`
do
    files_exists=1

    # *** apache ***
    if [ ! -f httpd-${apache_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing httpd-${apache_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` apache wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://ftp.riken.jp/net/apache//httpd/httpd-${apache_version}.tar.gz
        tarball_md5=$(md5sum httpd-${apache_version}.tar.gz | cut -d ' ' -f 1)
        apache_md5=$(curl -Ls http://www.apache.org/dist/httpd/httpd-${apache_version}.tar.gz.md5 | cut -d ' ' -f 1)
        if [ "${tarball_md5}" != "${apache_md5}" ]; then
            echo `date +%Y/%m/%d" "%H:%M:%S` apache md5 unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            echo `date +%Y/%m/%d" "%H:%M:%S` apache md5 unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
            rm httpd-${apache_version}.tar.gz
        fi
    fi
    [ -f httpd-${apache_version}.tar.gz ] || files_exists=0

    # *** rbenv-installer ***
    if [ ! -f rbenv-installer ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` rbenv-installer wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.github.com/Seppone/openshift-rbenv-installer/master/bin/rbenv-installer
    fi
    [ -f rbenv-installer ] || files_exists=0

    # *** redmine ***
    if [ ! -f redmine-${redmine_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing redmine-${redmine_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` redmine wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.redmine.org/releases/redmine-${redmine_version}.tar.gz
    fi
    [ -f redmine-${redmine_version}.tar.gz ] || files_exists=0

    # *** Gemfile_redmine_custom ***
    if [ ! -f Gemfile_redmine_custom ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` Gemfile_redmine_custom wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app01/Gemfile_redmine_custom
    fi
    [ -f Gemfile_redmine_custom ] || files_exists=0

    # # *** redmine_logs ***
    # if [ ! -f redmine_logs-0.0.5.zip ]; then
    #     echo `date +%Y/%m/%d" "%H:%M:%S` redmine_logs wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget https://bitbucket.org/haru_iida/redmine_logs/downloads/redmine_logs-0.0.5.zip
    # fi
    # [ -f redmine_logs-0.0.5.zip ] || files_exists=0

    # *** bash.rb ***
    if [ ! -f bash.rb ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` bash.rb wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app01/bash.rb
    fi
    [ -f bash.rb ] || files_exists=0

    # *** ipa font ***
    # if [ ! -f IPAfont${ipafont_version}.zip ]; then
    #     echo `date +%Y/%m/%d" "%H:%M:%S` ipa font wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget http://ipafont.ipa.go.jp/ipafont/IPAfont${ipafont_version}.php -O IPAfont${ipafont_version}.zip
    # fi
    # [ -f IPAfont${ipafont_version}.zip ] || files_exists=0
    if [ ! -f ipagp${ipafont_version}.zip ]; then
       echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing ipa font | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
       echo `date +%Y/%m/%d" "%H:%M:%S` ipa font wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
       wget http://ipafont.ipa.go.jp/ipafont/ipagp${ipafont_version}.php -O ipagp${ipafont_version}.zip
    fi
    [ -f ipagp${ipafont_version}.zip ] || files_exists=0

    # *** memcached ***
    if [ ! -f memcached-${memcached_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing memcached-${memcached_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` memcached wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.memcached.org/files/memcached-${memcached_version}.tar.gz
    fi
    [ -f memcached-${memcached_version}.tar.gz ] || files_exists=0

    # *** memcached-tool ***
    if [ ! -f memcached-tool ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` memcached-tool wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/memcached/memcached/master/scripts/memcached-tool
    fi
    [ -f memcached-tool ] || files_exists=0

    # *** php ***
    if [ ! -f php-${php_version}.tar.xz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing php-${php_version}.tar.xz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` php wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://jp1.php.net/get/php-${php_version}.tar.xz/from/this/mirror -O php-${php_version}.tar.xz
    fi
    [ -f php-${php_version}.tar.xz ] || files_exists=0

    # *** libmemcached ***
    if [ ! -f libmemcached-${libmemcached_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing libmemcached-${libmemcached_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz
        tarball_md5=$(md5sum libmemcached-${libmemcached_version}.tar.gz | cut -d ' ' -f 1)
        libmemcached_md5=$(curl -Ls https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz/+md5 | cut -d ' ' -f 1)
        if [ "${tarball_md5}" != "${libmemcached_md5}" ]; then
            echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached md5 unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            rm libmemcached-${libmemcached_version}.tar.gz
        fi
    fi
    [ -f libmemcached-${libmemcached_version}.tar.gz ] || files_exists=0

    # *** memcached (php extension) ***
    if [ ! -f memcached-${memcached_php_ext_version}.tgz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing memcached-${memcached_php_ext_version}.tgz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` memcached php extension wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://pecl.php.net/get/memcached-${memcached_php_ext_version}.tgz
    fi
    [ -f memcached-${memcached_php_ext_version}.tgz ] || files_exists=0

    # *** delegate ***
    # * src *
    # make済みバイナリが github に有る。
    if [ ! -f delegate${delegate_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing delegate${delegate_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` delegate wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.delegate.org/anonftp/DeleGate/delegate${delegate_version}.tar.gz
    fi
    [ -f delegate${delegate_version}.tar.gz ] || files_exists=0

    # *** mrtg ***
    if [ ! -f mrtg-${mrtg_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing mrtg-${mrtg_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` mrtg wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://oss.oetiker.ch/mrtg/pub/mrtg-${mrtg_version}.tar.gz
        tarball_md5=$(md5sum mrtg-${mrtg_version}.tar.gz | cut -d ' ' -f 1)
        mrtg_md5=$(curl -Ls http://oss.oetiker.ch/mrtg/pub/mrtg-${mrtg_version}.tar.gz.md5 | cut -d ' ' -f 1)
        if [ "${tarball_md5}" != "${mrtg_md5}" ]; then
            echo `date +%Y/%m/%d" "%H:%M:%S` mrtg md5 unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            rm mrtg-${mrtg_version}.tar.gz
        fi
    fi
    [ -f mrtg-${mrtg_version}.tar.gz ] || files_exists=0

    # *** webalizer ***
    if [ ! -f webalizer-${webalizer_version}-src.tgz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing webalizer-${webalizer_version}-src.tgz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` webalizer wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget ftp://ftp.mrunix.net/pub/webalizer/webalizer-${webalizer_version}-src.tgz
    fi
    [ -f webalizer-${webalizer_version}-src.tgz ] || files_exists=0

    # *** wordpress ja ***
    if [ ! -f wordpress-${wordpress_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing wordpress-${wordpress_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` wordpress wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://ja.wordpress.org/wordpress-${wordpress_version}.tar.gz
    fi
    [ -f wordpress-${wordpress_version}.tar.gz ] || files_exists=0

    # # *** is_ssl.php ***
    # if [ ! -f is_ssl.php ]; then
    #     echo `date +%Y/%m/%d" "%H:%M:%S` is_ssl.php wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget https://gist.githubusercontent.com/franz-josef-kaiser/1891564/raw/9d3f519c1cfb0fff9ad5ca31f3e783deaf5d561c/is_ssl.php
    # fi
    # [ -f is_ssl.php ] || files_exists=0

    # *** Tiny Tiny RSS ***
    if [ ! -f ${ttrss_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing ${ttrss_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` Tiny Tiny RSS wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://github.com/gothfox/Tiny-Tiny-RSS/archive/${ttrss_version}.tar.gz
    fi
    [ -f ${ttrss_version}.tar.gz ] || files_exists=0

    # *** cacti ***
    if [ ! -f cacti-${cacti_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing cacti-${cacti_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` cacti wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.cacti.net/downloads/cacti-${cacti_version}.tar.gz
    fi
    [ -f cacti-${cacti_version}.tar.gz ] || files_exists=0

    # # *** cacti patch ***
    # # patch -p1 -N < security.patch
    # if [ ! -f security.patch ]; then
    #     echo `date +%Y/%m/%d" "%H:%M:%S` cacti patch wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget http://www.cacti.net/downloads/patches/${cacti_version}/security.patch
    # fi
    # [ -f security.patch ] || files_exists=0

    # *** mURLin ***
    if [ ! -f mURLin-${murlin_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mURLin wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing mURLin-${murlin_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        wget http://downloads.sourceforge.net/project/murlin/mURLin-${murlin_version}.tar.gz
    fi
    [ -f mURLin-${murlin_version}.tar.gz ] || files_exists=0

    # *** Tcl ***
    if [ ! -f tcl${tcl_version}-src.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing tcl${tcl_version}-src.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` Tcl wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://prdownloads.sourceforge.net/tcl/tcl${tcl_version}-src.tar.gz
    fi
    [ -f tcl${tcl_version}-src.tar.gz ] || files_exists=0

    # *** Expect ***
    if [ ! -f expect${expect_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing expect${expect_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` Expect wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://downloads.sourceforge.net/project/expect/Expect/${expect_version}/expect${expect_version}.tar.gz
    fi
    [ -f expect${expect_version}.tar.gz ] || files_exists=0

    # *** nginx ***
    if [ ! -f nginx-${nginx_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing nginx-${nginx_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` nginx wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://nginx.org/download/nginx-${nginx_version}.tar.gz
    fi
    [ -f nginx-${nginx_version}.tar.gz ] || files_exists=0

    # *** pcre ***
    if [ ! -f pcre-${pcre_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing pcre-${pcre_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` pcre wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${pcre_version}.tar.gz
    fi
    [ -f pcre-${pcre_version}.tar.gz ] || files_exists=0

    # *** xymon ***
    if [ ! -f xymon-${xymon_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing xymon-${xymon_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` xymon wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://downloads.sourceforge.net/project/xymon/Xymon/${xymon_version}/xymon-${xymon_version}.tar.gz
    fi
    [ -f xymon-${xymon_version}.tar.gz ] || files_exists=0

    # # *** fping ***
    # if [ ! -f fping-${fping_version}.tar.gz ]; then
    #     echo `date +%Y/%m/%d" "%H:%M:%S` fping wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     wget http://fping.org/dist/fping-${fping_version}.tar.gz
    # fi
    # [ -f fping-${fping_version}.tar.gz ] || files_exists=0

    # # *** c-ares ***
    # if [ ! -f c-ares-${c-ares_version}.tar.gz ]; then
    #   echo `date +%Y/%m/%d" "%H:%M:%S` c-ares wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #   wget http://c-ares.haxx.se/download/c-ares-${c-ares_version}.tar.gz
    # fi
    # [ -f c-ares-${c-ares_version}.tar.gz ] || files_exists=0

    # *** logrotate ***
    if [ ! -f logrotate-${logrotate_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing logrotate-${logrotate_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` logrotate wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://fedorahosted.org/releases/l/o/logrotate/logrotate-${logrotate_version}.tar.gz
    fi
    [ -f logrotate-${logrotate_version}.tar.gz ] || files_exists=0

    # *** Lynx ***
    if [ ! -f lynx${lynx_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mirror nothing lynx${lynx_version}.tar.gz | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo `date +%Y/%m/%d" "%H:%M:%S` Lynx wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://lynx.isc.org/lynx${lynx_version}/lynx${lynx_version}.tar.gz
    fi
    [ -f lynx${lynx_version}.tar.gz ] || files_exists=0

    # *** etc ***

    if [ ! -f salt.txt ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` salt.txt wget | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        curl -o ./salt.txt https://api.wordpress.org/secret-key/1.1/salt/
    fi
    [ -f salt.txt ] || files_exists=0

    if [ ${files_exists} -eq 1 ]; then
        break
    else
        sleep 10s
    fi
done

popd > /dev/null

if [ ${files_exists} -eq 0 ]; then
    echo `date +%Y/%m/%d" "%H:%M:%S` Abort Install miss download files | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    exit
fi

# ***** make directories *****

mkdir ${OPENSHIFT_DATA_DIR}/tmp
mkdir ${OPENSHIFT_DATA_DIR}/etc
mkdir -p ${OPENSHIFT_DATA_DIR}/var/www/cgi-bin
mkdir ${OPENSHIFT_DATA_DIR}/bin
mkdir ${OPENSHIFT_DATA_DIR}/scripts

touch ${OPENSHIFT_DATA_DIR}/install_check_point/`basename $0`.ok

export TMOUT=0

set +x

if [ -f ${OPENSHIFT_LOG_DIR}/install_alert.log ]; then
    echo '***** ALERT *****'
    ${OPENSHIFT_LOG_DIR}/install_alert.log
    echo
fi

echo cd ${OPENSHIFT_DATA_DIR}/github/openshift/app01
echo "nohup ./install_step_from_2_to_16.sh > ${OPENSHIFT_LOG_DIR}/nohup.log 2> ${OPENSHIFT_LOG_DIR}/nohup_error.log &"

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 1 Finish | tee -a ${OPENSHIFT_LOG_DIR}/install.log
