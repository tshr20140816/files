#!/bin/bash

set -x

# History
# 2014.11.13 first

cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/version_list
apache_version 2.2.29
cacti_version 0.8.8b
murlin_version 0.2.4
tcl_version 8.6.2
expect_version 5.45
lynx_version 2.8.7
fping_version 3.2
pcre_version 8.36
xymon_version 4.3.17
__HEREDOC__

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 1 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** git *****

echo `date +%Y/%m/%d" "%H:%M:%S` github >> ${OPENSHIFT_LOG_DIR}/install.log

curl -L https://status.github.com/api/status.json >> ${OPENSHIFT_LOG_DIR}/install.log
echo >> ${OPENSHIFT_LOG_DIR}/install.log

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
        echo `date +%Y/%m/%d" "%H:%M:%S` apache wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://ftp.riken.jp/net/apache//httpd/httpd-${apache_version}.tar.gz
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

    # *** cacti ***
    if [ ! -f cacti-${cacti_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` cacti wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.cacti.net/downloads/cacti-${cacti_version}.tar.gz
    fi
    if [ ! -f cacti-${cacti_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** cacti patch ***
    # patch -p1 -N < security.patch
    if [ ! -f security.patch ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` cacti patch wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.cacti.net/downloads/patches/${cacti_version}/security.patch
    fi
    if [ ! -f security.patch ]; then
        files_exists=0
    fi

    # *** mURLin ***
    if [ ! -f mURLin-${murlin_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mURLin wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://downloads.sourceforge.net/project/murlin/mURLin-${murlin_version}.tar.gz
    fi
    if [ ! -f mURLin-${murlin_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** Tcl ***
    if [ ! -f tcl${tcl_version}-src.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` Tcl wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://prdownloads.sourceforge.net/tcl/tcl${tcl_version}-src.tar.gz
    fi
    if [ ! -f tcl${tcl_version}-src.tar.gz ]; then
        files_exists=0
    fi

    # *** Expect ***
    if [ ! -f expect${expect_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` Expect wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://downloads.sourceforge.net/project/expect/Expect/${expect_version}/expect${expect_version}.tar.gz
    fi
    if [ ! -f expect${expect_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** pcre ***
    if [ ! -f pcre-${pcre_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` pcre wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${pcre_version}.tar.gz
    fi
    if [ ! -f pcre-${pcre_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** xymon ***
    if [ ! -f xymon-${xymon_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` xymon wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://downloads.sourceforge.net/project/xymon/Xymon/${xymon_version}/xymon-${xymon_version}.tar.gz
    fi
    if [ ! -f xymon-${xymon_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** Lynx ***
    if [ ! -f lynx${lynx_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` Lynx wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://lynx.isc.org/lynx${lynx_version}/lynx${lynx_version}.tar.gz
    fi
    if [ ! -f lynx${lynx_version}.tar.gz ]; then
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

# ***** make directories *****

mkdir ${OPENSHIFT_DATA_DIR}/tmp
mkdir ${OPENSHIFT_DATA_DIR}/etc
mkdir -p ${OPENSHIFT_DATA_DIR}/var/www/cgi-bin
mkdir ${OPENSHIFT_DATA_DIR}/bin
mkdir ${OPENSHIFT_DATA_DIR}/scripts

export TMOUT=0

set +x
echo cd ${OPENSHIFT_DATA_DIR}/github/openshift/app02
# echo "nohup ./install_step_from_2_to_16.sh > ${OPENSHIFT_LOG_DIR}/nohup.log 2> ${OPENSHIFT_LOG_DIR}/nohup_error.log &"

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 1 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
