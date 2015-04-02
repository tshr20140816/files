#!/bin/bash

set -x

# History
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
apache_version 2.2.29
php_version 5.6.7
delegate_version 9.9.13
mrtg_version 2.17.4
webalizer_version 2.23-08
wordpress_version 4.1.1-ja
ttrss_version 1.15.3
memcached_version 1.4.22
libmemcached_version 1.0.18
memcached_php_ext_version 2.2.0
ruby_version 2.1.5
redmine_version 2.6.3
ipafont_version 00303
cacti_version 0.8.8c
murlin_version 0.2.4
tcl_version 8.6.3
expect_version 5.45
lynx_version 2.8.7
logrotate_version 3.8.8
fio_version 2.2.5
baikal_version 0.2.7
caldavzap_version 0.12.1
phpicalendar_version 2.4_20100615
__HEREDOC__

# nginx_version 1.6.2
# pcre_version 8.36
# xymon_version 4.3.18
# fping_version 3.10
# unix_bench_version 5.1.3
# sysbench_version 0.4.12.5
# c-ares_version 1.10.0

# http://httpd.apache.org/
# http://php.net/
# http://delegate.hpcc.jp/delegate/
# https://www.ruby-lang.org/ja/

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

if [ $# -ne 12 ]; then
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
    echo "arg12 : files download mirror server (http://xxx/files/ / none)"
    echo "arg13 : schedule server (fqdn)"
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
schedule_server=${12}

rm -rf ${OPENSHIFT_DATA_DIR}/params
mkdir ${OPENSHIFT_DATA_DIR}/params

echo "${redmine_email_address}" > ${OPENSHIFT_DATA_DIR}/params/redmine_email_address
echo "${redmine_email_password}" > ${OPENSHIFT_DATA_DIR}/params/redmine_email_password
echo "${openshift_email_address}" > ${OPENSHIFT_DATA_DIR}/params/openshift_email_address
echo "${openshift_email_password}" > ${OPENSHIFT_DATA_DIR}/params/openshift_email_password
echo "${delegate_email_account}" > ${OPENSHIFT_DATA_DIR}/params/delegate_email_account
echo "${delegate_email_password}" > ${OPENSHIFT_DATA_DIR}/params/delegate_email_password
echo "${delegate_pop_server}" > ${OPENSHIFT_DATA_DIR}/params/delegate_pop_server
echo "${another_server_check}" > ${OPENSHIFT_DATA_DIR}/params/another_server_check
echo "${web_beacon_server}" > ${OPENSHIFT_DATA_DIR}/params/web_beacon_server
echo "${web_beacon_server_user}" > ${OPENSHIFT_DATA_DIR}/params/web_beacon_server_user
echo "${schedule_server}" > ${OPENSHIFT_DATA_DIR}/params/schedule_server

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
popd > /dev/null

# ***** download files *****

rm -f ${OPENSHIFT_LOG_DIR}/install_alert.log
rm -rf ${OPENSHIFT_DATA_DIR}/download_files
mkdir ${OPENSHIFT_DATA_DIR}/download_files
pushd ${OPENSHIFT_DATA_DIR}/download_files > /dev/null

# *** 必要なファイルの事前ダウンロード 成功まで10回繰り返す ***

# * gpg *

rm -rf ${OPENSHIFT_DATA_DIR}/.gnupg
mkdir ${OPENSHIFT_DATA_DIR}/.gnupg
export GNUPGHOME=${OPENSHIFT_DATA_DIR}/.gnupg
gpg --list-keys
echo "keyserver hkp://keyserver.ubuntu.com:80" >> ${GNUPGHOME}/gpg.conf

# * まずミラーサーバよりダウンロード *

if [ "${mirror_server}" != "none" ]; then
    # apache
    wget -t1 ${mirror_server}/httpd-${apache_version}.tar.bz2
    tarball_md5=$(md5sum httpd-${apache_version}.tar.bz2 | cut -d ' ' -f 1)
    apache_md5=$(curl -Ls http://www.apache.org/dist/httpd/httpd-${apache_version}.tar.bz2.md5 | cut -d ' ' -f 1)
    if [ "${tarball_md5}" != "${apache_md5}" ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) apache md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) apache md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm httpd-${apache_version}.tar.bz2
    fi

    # libmemcached
    wget -t1 ${mirror_server}/libmemcached-${libmemcached_version}.tar.gz
    tarball_md5=$(md5sum libmemcached-${libmemcached_version}.tar.gz | cut -d ' ' -f 1)
    libmemcached_md5=$(curl -Ls https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz/+md5 | cut -d ' ' -f 1)
    if [ "${tarball_md5}" != "${libmemcached_md5}" ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) libmemcached md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm libmemcached-${libmemcached_version}.tar.gz
    fi

    # mrtg
    wget -t1 ${mirror_server}/mrtg-${mrtg_version}.tar.gz
    tarball_md5=$(md5sum mrtg-${mrtg_version}.tar.gz | cut -d ' ' -f 1)
    mrtg_md5=$(curl -Ls http://oss.oetiker.ch/mrtg/pub/mrtg-${mrtg_version}.tar.gz.md5 | cut -d ' ' -f 1)
    if [ "${tarball_md5}" != "${mrtg_md5}" ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mrtg md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mrtg md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm mrtg-${mrtg_version}.tar.gz
    fi

    # ipa font
    wget -t1 ${mirror_server}/ipagp${ipafont_version}.zip

    # php
    wget -t1 ${mirror_server}/php-${php_version}.tar.xz
    wget http://jp1.php.net/distributions/php-${php_version}.tar.xz.asc
    gpg --recv-keys $(gpg --verify php-${php_version}.tar.xz.asc 2>&1 | grep "RSA key ID" | awk '{print $NF}')
    if [ $(gpg --verify php-${php_version}.tar.xz.asc 2>&1 | grep -c "Good signature from") != 1 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) php pgp unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) php pgp unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm php-${php_version}.tar.xz
    fi

    # delegate
    # TODO check
    wget -t1 ${mirror_server}/delegate${delegate_version}.tar.gz

    # redmine
    wget -t1 ${mirror_server}/redmine-${redmine_version}.tar.gz
    tarball_md5=$(md5sum redmine-${redmine_version}.tar.gz | cut -d ' ' -f 1)
    redmine_md5=$(curl http://www.redmine.org/projects/redmine/wiki/Download -s \
    | grep md5 \
    | grep "redmine-${redmine_version}.tar.gz" \
    | awk '{print substr(substr($0, index($0, "md5: ")), 6, 32)}')
    if [ "${tarball_md5}" != "${redmine_md5}" ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) redmine md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) redmine md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm redmine-${redmine_version}.tar.gz
    fi

    # webalizer
    wget -t1 ${mirror_server}/webalizer-${webalizer_version}-src.tar.bz2

    # wordpress
    wget -t1 ${mirror_server}/wordpress-${wordpress_version}.tar.gz
    tarball_md5=$(md5sum wordpress-${wordpress_version}.tar.gz | cut -d ' ' -f 1)
    wordpress_md5=$(curl -Ls https://ja.wordpress.org/wordpress-${wordpress_version}.tar.gz.md5)
    if [ "${tarball_md5}" != "${wordpress_md5}" ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) wordpress md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) wordpress md5 unmatch" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        rm wordpress-${wordpress_version}.tar.gz
    fi
    
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

    # # nginx
    # wget -t1 ${mirror_server}/nginx-${nginx_version}.tar.gz
    # wget http://nginx.org/download/nginx-${nginx_version}.tar.gz.asc
    # gpg --recv-keys $(gpg --verify nginx-${nginx_version}.tar.gz.asc 2>&1 | grep "RSA key ID" | awk '{print $NF}')
    # if [ $(gpg --verify nginx-${nginx_version}.tar.gz.asc 2>&1 | grep -c "Good signature from") != 1 ]; then
    #     echo $(date +%Y/%m/%d" "%H:%M:%S) nginx pgp unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    #     echo $(date +%Y/%m/%d" "%H:%M:%S) nginx pgp unmatch | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
    #     rm nginx-${nginx_version}.tar.gz
    # fi

    # memcached
    wget -t1 ${mirror_server}/memcached-${memcached_version}.tar.gz
    # memcached(php extension)
    wget -t1 ${mirror_server}/memcached-${memcached_php_ext_version}.tgz
    # mURLin
    wget -t1 ${mirror_server}/mURLin-${murlin_version}.tar.gz
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
    
    # fio
    wget -t1 ${mirror_server}/fio-${fio_version}.tar.bz2
    
    # Baikal
    wget -t1 ${mirror_server}/baikal-flat-${baikal_version}.zip

    # CalDavZAP
    wget -t1 ${mirror_server}/CalDavZAP_${caldavzap_version}.zip

    # phpicalendar
    wget -t1 ${mirror_server}/phpicalendar-${phpicalendar_version}.tar.bz2
fi

files_exists=0
for i in $(seq 0 9)
do
    files_exists=1

    # *** apache ***
    if [ ! -f httpd-${apache_version}.tar.bz2 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing httpd-${apache_version}.tar.bz2" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
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

    # *** spdy ***
    if [ ! -f mod-spdy-beta_current_x86_64.rpm ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) spdy wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://dl-ssl.google.com/dl/linux/direct/mod-spdy-beta_current_x86_64.rpm
    fi

    # *** rbenv-installer ***
    if [ ! -f rbenv-installer ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) rbenv-installer wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.github.com/Seppone/openshift-rbenv-installer/master/bin/rbenv-installer
    fi
    [ -f rbenv-installer ] || files_exists=0

    # *** redmine ***
    if [ ! -f redmine-${redmine_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing redmine-${redmine_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) redmine wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.redmine.org/releases/redmine-${redmine_version}.tar.gz
    fi
    [ -f redmine-${redmine_version}.tar.gz ] || files_exists=0

    # *** Gemfile_redmine_custom ***
    if [ ! -f Gemfile_redmine_custom ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Gemfile_redmine_custom wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app01/Gemfile_redmine_custom
    fi
    [ -f Gemfile_redmine_custom ] || files_exists=0

    # *** bash.rb ***
    if [ ! -f bash.rb ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) bash.rb wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app01/bash.rb
    fi
    [ -f bash.rb ] || files_exists=0

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
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing memcached-${memcached_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.memcached.org/files/memcached-${memcached_version}.tar.gz
    fi
    [ -f memcached-${memcached_version}.tar.gz ] || files_exists=0

    # *** memcached-tool ***
    if [ ! -f memcached-tool ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached-tool wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/memcached/memcached/master/scripts/memcached-tool
    fi
    [ -f memcached-tool ] || files_exists=0

    # *** php ***
    if [ ! -f php-${php_version}.tar.xz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing php-${php_version}.tar.xz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) php wget" >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://jp1.php.net/get/php-${php_version}.tar.xz/from/this/mirror -O php-${php_version}.tar.xz
    fi
    [ -f php-${php_version}.tar.xz ] || files_exists=0

    # *** libmemcached ***
    if [ ! -f libmemcached-${libmemcached_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing libmemcached-${libmemcached_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
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
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing memcached-${memcached_php_ext_version}.tgz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) memcached php extension wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://pecl.php.net/get/memcached-${memcached_php_ext_version}.tgz
    fi
    [ -f memcached-${memcached_php_ext_version}.tgz ] || files_exists=0

    # *** delegate ***
    if [ ! -f delegate${delegate_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing delegate${delegate_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) delegate wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.delegate.org/anonftp/DeleGate/delegate${delegate_version}.tar.gz
    fi
    [ -f delegate${delegate_version}.tar.gz ] || files_exists=0

    # *** mrtg ***
    if [ ! -f mrtg-${mrtg_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing mrtg-${mrtg_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
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
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing webalizer-${webalizer_version}-src.tar.bz2" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) webalizer wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget ftp://ftp.mrunix.net/pub/webalizer/webalizer-${webalizer_version}-src.tar.bz2
    fi
    [ -f webalizer-${webalizer_version}-src.tar.bz2 ] || files_exists=0

    # *** wordpress ja ***
    if [ ! -f wordpress-${wordpress_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing wordpress-${wordpress_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) wordpress wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://ja.wordpress.org/wordpress-${wordpress_version}.tar.gz
    fi
    [ -f wordpress-${wordpress_version}.tar.gz ] || files_exists=0

    # *** Tiny Tiny RSS ***
    if [ ! -f ${ttrss_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing ${ttrss_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Tiny Tiny RSS wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://github.com/gothfox/Tiny-Tiny-RSS/archive/${ttrss_version}.tar.gz
    fi
    [ -f ${ttrss_version}.tar.gz ] || files_exists=0

    # *** cacti ***
    if [ ! -f cacti-${cacti_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing cacti-${cacti_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) cacti wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.cacti.net/downloads/cacti-${cacti_version}.tar.gz
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
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing mURLin-${murlin_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        wget http://downloads.sourceforge.net/project/murlin/mURLin-${murlin_version}.tar.gz
    fi
    [ -f mURLin-${murlin_version}.tar.gz ] || files_exists=0

    # *** Tcl ***
    if [ ! -f tcl${tcl_version}-src.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing tcl${tcl_version}-src.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Tcl wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://prdownloads.sourceforge.net/tcl/tcl${tcl_version}-src.tar.gz
    fi
    [ -f tcl${tcl_version}-src.tar.gz ] || files_exists=0

    # *** Expect ***
    if [ ! -f expect${expect_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing expect${expect_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Expect wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://downloads.sourceforge.net/project/expect/Expect/${expect_version}/expect${expect_version}.tar.gz
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
    if [ ! -f logrotate-${logrotate_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing logrotate-${logrotate_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) logrotate wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://fedorahosted.org/releases/l/o/logrotate/logrotate-${logrotate_version}.tar.gz
    fi
    [ -f logrotate-${logrotate_version}.tar.gz ] || files_exists=0

    # *** Lynx ***
    if [ ! -f lynx${lynx_version}.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing lynx${lynx_version}.tar.gz" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Lynx wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://lynx.isc.org/lynx${lynx_version}/lynx${lynx_version}.tar.gz
    fi
    [ -f lynx${lynx_version}.tar.gz ] || files_exists=0

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
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing fio-${fio_version}.tar.bz2" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) fio wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://brick.kernel.dk/snaps/fio-${fio_version}.tar.bz2
    fi
    [ -f fio-${fio_version}.tar.bz2 ] || files_exists=0

    # *** Baikal ***
    if [ ! -f baikal-flat-${baikal_version}.zip ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing baikal-flat-${baikal_version}.zip" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Baikal wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://baikal-server.com/get/baikal-flat-${baikal_version}.zip
    fi
    [ -f baikal-flat-${baikal_version}.zip ] || files_exists=0

    # *** ical_multi ***
    if [ ! -f ical_multi.sh ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) ical_multi.sh wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app01/ical_multi.sh
    fi

    # *** CalDavZAP ***
    if [ ! -f CalDavZAP_${caldavzap_version}.zip ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing CalDavZAP_${caldavzap_version}.zip" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) CalDavZAP wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.inf-it.com/CalDavZAP_${caldavzap_version}.zip
    fi
    [ -f CalDavZAP_${caldavzap_version}.zip ] || files_exists=0

    # *** phpicalendar ***
    if [ ! -f phpicalendar-${phpicalendar_version}.tar.bz2 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) mirror nothing phpicalendar-${phpicalendar_version}.tar.bz2" | tee -a ${OPENSHIFT_LOG_DIR}/install_alert.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) phpicalendar wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget http://downloads.sourceforge.net/project/phpicalendar/phpicalendar/phpicalendar%202.4%20RC7/phpicalendar-${phpicalendar_version}.tar.bz2
    fi
    [ -f phpicalendar-${phpicalendar_version}.tar.bz2 ] || files_exists=0

    # *** super pi ***
    if [ ! -f super_pi-jp.tar.gz ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) super pi wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        wget ftp://pi.super-computing.org/Linux_jp/super_pi-jp.tar.gz
    fi

    # *** etc ***

    if [ ! -f salt.txt ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) salt.txt wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        curl -o ./salt.txt https://api.wordpress.org/secret-key/1.1/salt/
    fi
    [ -f salt.txt ] || files_exists=0

    if [ "${files_exists}" -eq 1 ]; then
        break
    else
        sleep 10s
    fi
done

popd > /dev/null

if [ ${files_exists} -eq 0 ]; then
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Abort Install miss download files" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    exit
fi

# ***** install log *****

touch ${OPENSHIFT_LOG_DIR}/nohup.log
touch ${OPENSHIFT_LOG_DIR}/nohup_error.log
mkdir ${OPENSHIFT_LOG_DIR}/install

# ***** install script *****

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null
rm -f *
touch jobs.deny

cat << '__HEREDOC__' > install_script_check.sh
#!/bin/bash

if [ -f ${OPENSHIFT_DATA_DIR}/install_check_point/install_all.ok ]; then
    echo "please remove this cron !!! $(basename "${0}")"
    exit
fi

# OPENSHIFT_DIY_IP is marker
install_script_file='install_step_from_2_to_18'
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
chmod +x install_script_check.sh
echo install_script_check.sh >> jobs.allow

popd > /dev/null

chmod +x ${OPENSHIFT_DATA_DIR}/github/openshift/app01/reboot_agent.sh
${OPENSHIFT_DATA_DIR}/github/openshift/app01/reboot_agent.sh >> ${OPENSHIFT_LOG_DIR}/reboot_agent.log 2>&1 &

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

export TMOUT=0

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

set +x

if [ -f ${OPENSHIFT_LOG_DIR}/install_alert.log ]; then
    echo '***** ALERT *****'
    cat ${OPENSHIFT_LOG_DIR}/install_alert.log
    echo
fi

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
