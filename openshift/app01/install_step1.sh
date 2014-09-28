#!/bin/bash

set -x

# TODO
# ruby_version 2.1.2 → 2.1.3

cat << '__HEREDOC__' >> ${OPENSHIFT_DATA_DIR}/version_list
apache_version 2.2.29
php_version 5.6.0
delegate_version 9.9.11
mrtg_version 2.17.4
webalizer_version 2.23-08
wordpress_version 4.0-ja
ttrss_version 1.13
memcached_version 1.4.20
libmemcached_version 1.0.18
memcached_php_ext_version 2.2.0
ruby_version 2.1.2
redmine_version 2.5.2
ipafont_version 00303
__HEREDOC__

while read LINE
do
  product=`echo $LINE | awk '{print $1}'`
  version=`echo $LINE | awk '{print $2}'`
  eval "$product"=$version
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 1 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** git *****

echo `date +%Y/%m/%d" "%H:%M:%S` github >> ${OPENSHIFT_LOG_DIR}/install.log

mkdir ${OPENSHIFT_DATA_DIR}/github
pushd ${OPENSHIFT_DATA_DIR}/github > /dev/null
git init
git remote add origin https://github.com/tshr20140816/files.git
git pull origin master
popd > /dev/null

# ***** download files *****

mkdir ${OPENSHIFT_DATA_DIR}/download_files
pushd ${OPENSHIFT_DATA_DIR}/download_files > /dev/null

# *** 必要なファイルの事前ダウンロード 成功まで10回繰り返す ***

files_exists=0
for i in `seq 0 9`
do
    files_exists=1

    # *** apache ***
    if [ ! -f httpd-${apache_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` apache wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.gtlib.gatech.edu/pub/apache//httpd/httpd-${apache_version}.tar.gz
        tarball_md5=$(md5sum httpd-${apache_version}.tar.gz | cut -d ' ' -f 1)
        apache_md5=$(curl -Ls http://www.apache.org/dist/httpd/httpd-${apache_version}.tar.gz.md5 | cut -d ' ' -f 1)
        if [ "${tarball_md5}" != "${apache_md5}" ]; then
            echo `date +%Y/%m/%d" "%H:%M:%S` apache md5 unmatch >> ${OPENSHIFT_LOG_DIR}/install.log
            rm httpd-${apache_version}.tar.gz
        fi
    fi
    if [ ! -f httpd-${apache_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** rbenv-installer ***
    if [ ! -f rbenv-installer ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` rbenv-installer wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.github.com/Seppone/openshift-rbenv-installer/master/bin/rbenv-installer
    fi
    if [ ! -f rbenv-installer ]; then
        files_exists=0
    fi

    # *** redmine ***
    if [ ! -f redmine-${redmine_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` redmine wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.redmine.org/releases/redmine-${redmine_version}.tar.gz
    fi
    if [ ! -f redmine-${redmine_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** Gemfile_redmine_custom ***
    if [ ! -f Gemfile_redmine_custom ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` Gemfile_redmine_custom wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app01/Gemfile_redmine_custom
    fi
    if [ ! -f Gemfile_redmine_custom ]; then
        files_exists=0
    fi

    # *** redmine_logs ***
    if [ ! -f redmine_logs-0.0.5.zip ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` redmine_logs wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget https://bitbucket.org/haru_iida/redmine_logs/downloads/redmine_logs-0.0.5.zip
    fi
    if [ ! -f redmine_logs-0.0.5.zip ]; then
        files_exists=0
    fi

    # *** bash.rb ***
    if [ ! -f bash.rb ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` bash.rb wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app01/bash.rb
    fi
    if [ ! -f bash.rb ]; then
        files_exists=0
    fi

    # *** ipa font ***
    # if [ ! -f IPAfont${ipafont_version}.zip ]; then
    #     echo `date +%Y/%m/%d" "%H:%M:%S` ipa font wget >> ${OPENSHIFT_LOG_DIR}/install.log
    #     wget http://ipafont.ipa.go.jp/ipafont/IPAfont${ipafont_version}.php -O IPAfont${ipafont_version}.zip
    # fi
    # if [ ! -f IPAfont${ipafont_version}.zip ]; then
    #     files_exists=0
    # fi
    if [ ! -f ipagp${ipafont_version}.zip ]; then
       echo `date +%Y/%m/%d" "%H:%M:%S` ipa font wget >> ${OPENSHIFT_LOG_DIR}/install.log
       wget http://ipafont.ipa.go.jp/ipafont/ipagp${ipafont_version}.php -O ipagp${ipafont_version}.zip
    fi
    if [ ! -f ipagp${ipafont_version}.zip ]; then
       files_exists=0
    fi

    # *** memcached ***
    if [ ! -f memcached-${memcached_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` memcached wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.memcached.org/files/memcached-${memcached_version}.tar.gz
    fi
    if [ ! -f memcached-${memcached_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** php ***
    if [ ! -f php-${php_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` php wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://jp1.php.net/get/php-${php_version}.tar.gz/from/this/mirror -O php-${php_version}.tar.gz
    fi
    if [ ! -f php-${php_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** libmemcached ***
    if [ ! -f libmemcached-${libmemcached_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz
        tarball_md5=$(md5sum libmemcached-${libmemcached_version}.tar.gz | cut -d ' ' -f 1)
        libmemcached_md5=$(curl -Ls https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz/+md5 | cut -d ' ' -f 1)
        if [ "${tarball_md5}" != "${libmemcached_md5}" ]; then
            echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached md5 unmatch >> ${OPENSHIFT_LOG_DIR}/install.log
            rm libmemcached-${libmemcached_version}.tar.gz
        fi
    fi
    if [ ! -f libmemcached-${libmemcached_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** memcached (php extension) ***
    if [ ! -f memcached-${memcached_php_ext_version}.tgz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` memcached php extension wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://pecl.php.net/get/memcached-${memcached_php_ext_version}.tgz
    fi
    if [ ! -f memcached-${memcached_php_ext_version}.tgz ]; then
        files_exists=0
    fi

    # *** delegate ***
    # * src *
    # make済みバイナリが github に有る。
    if [ ! -f delegate${delegate_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` delegate wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.delegate.org/anonftp/DeleGate/delegate${delegate_version}.tar.gz
    fi
    if [ ! -f delegate${delegate_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** mrtg ***
    if [ ! -f mrtg-${mrtg_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mrtg wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://oss.oetiker.ch/mrtg/pub/mrtg-${mrtg_version}.tar.gz
        tarball_md5=$(md5sum mrtg-${mrtg_version}.tar.gz | cut -d ' ' -f 1)
        mrtg_md5=$(curl -Ls http://oss.oetiker.ch/mrtg/pub/mrtg-${mrtg_version}.tar.gz.md5 | cut -d ' ' -f 1)
        if [ "${tarball_md5}" != "${mrtg_md5}" ]; then
            echo `date +%Y/%m/%d" "%H:%M:%S` mrtg md5 unmatch >> ${OPENSHIFT_LOG_DIR}/install.log
            rm mrtg-${mrtg_version}.tar.gz
        fi
    fi
    if [ ! -f mrtg-${mrtg_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** webalizer ***
    if [ ! -f webalizer-${webalizer_version}-src.tgz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` webalizer wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget ftp://ftp.mrunix.net/pub/webalizer/webalizer-${webalizer_version}-src.tgz
    fi
    if [ ! -f webalizer-${webalizer_version}-src.tgz ]; then
        files_exists=0
    fi

    # *** wordpress ja ***
    if [ ! -f wordpress-${wordpress_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` wordpress wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://ja.wordpress.org/wordpress-${wordpress_version}.tar.gz
    fi
    if [ ! -f wordpress-${wordpress_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** is_ssl.php ***
    if [ ! -f is_ssl.php ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` is_ssl.php wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget https://gist.githubusercontent.com/franz-josef-kaiser/1891564/raw/9d3f519c1cfb0fff9ad5ca31f3e783deaf5d561c/is_ssl.php
    fi
    if [ ! -f is_ssl.php ]; then
        files_exists=0
    fi

    # *** Tiny Tiny RSS ***
    if [ ! -f ${ttrss_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` Tiny Tiny RSS wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget https://github.com/gothfox/Tiny-Tiny-RSS/archive/${ttrss_version}.tar.gz
    fi
    if [ ! -f ${ttrss_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** Lynx ***
    if [ ! -f lynx2.8.7.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` Lynx wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://lynx.isc.org/lynx2.8.7/lynx2.8.7.tar.gz
    fi
    if [ ! -f lynx2.8.7.tar.gz ]; then
        files_exists=0
    fi

    # *** etc ***

    if [ ! -f salt.txt ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` salt.txt wget >> ${OPENSHIFT_LOG_DIR}/install.log
        curl -o ./salt.txt https://api.wordpress.org/secret-key/1.1/salt/
    fi
    if [ ! -f salt.txt ]; then
        files_exists=0
    fi

    if [ ${files_exists} -eq 1 ]; then
        break
    else
        sleep 10s
    fi
done

popd > /dev/null

if [ ${files_exists} -eq 0 ]; then
    echo `date +%Y/%m/%d" "%H:%M:%S` Abort Install miss download files >> ${OPENSHIFT_LOG_DIR}/install.log
    exit
fi

# ***** lynx *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/lynx2.8.7.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` lynx tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz lynx2.8.7.tar.gz

pushd lynx2-8-7 > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` lynx configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/lynx 2>&1 | tee ${OPENSHIFT_LOG_DIR}/lynx.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` lynx make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j4

echo `date +%Y/%m/%d" "%H:%M:%S` lynx make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install

popd > /dev/null

rm lynx2.8.7.tar.gz
rm -rf lynx2-8-7

popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 1 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
