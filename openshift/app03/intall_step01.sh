#!/bin/bash

# https://github.com/tshr20140816/app03/

set -x

cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/version_list
apache_version 2.4.23
apr_version 1.5.2
aprutil_version 1.5.4
ccache_version 3.3.3
pcre_version 8.39
php_version 7.1.0
wordpress_version 4.7-ja
__HEREDOC__

mkdir ${OPENSHIFT_DATA_DIR}/install_check_point

source functions.sh
function010
[ $? -eq 0 ] || exit

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Start $(basename "${0}")" | tee -a ${install_log}
echo "$(quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}')" | tee -a ${install_log}
echo "$(oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}')" | tee -a ${install_log}
echo "$(oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}')" | tee -a ${install_log}
echo "$(oo-cgroup-read memory.memsw.failcnt | awk '{printf "Swap Memory Fail Count : %\047d\n", $1}')" | tee -a ${install_log}

# ***** git *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) github" | tee -a ${install_log}

curl -L https://status.github.com/api/status.json | tee -a ${install_log}
echo | tee -a ${install_log}

rm -rf ${OPENSHIFT_DATA_DIR}/github
mkdir ${OPENSHIFT_DATA_DIR}/github
pushd ${OPENSHIFT_DATA_DIR}/github > /dev/null
git init
git remote add origin https://github.com/tshr20140816/files.git
git pull origin master
rm -rf openshift/{app01,app02,app04,app05,app06,app07}
rm -f openshift/*
popd > /dev/null

# ***** gpg *****

export GNUPGHOME=${OPENSHIFT_DATA_DIR}/.gnupg
rm -rf ${GNUPGHOME}
mkdir ${GNUPGHOME}
chmod 700 ${GNUPGHOME}
gpg --list-keys
echo "keyserver hkp://keyserver.ubuntu.com:80" >> ${GNUPGHOME}/gpg.conf
chmod 600 ${GNUPGHOME}/gpg.conf


# ***** syntax check *****

pushd ${OPENSHIFT_DATA_DIR}/github/openshift/app01/ > /dev/null

# *** shell ***

for file_name in *.sh
do
    if [ $(/bin/bash -n ${file_name} 2>&1 | wc -l) -gt 0 ]; then
        /bin/bash -n ${file_name} >> ${OPENSHIFT_LOG_DIR}/install_alert.log 2>&1
    fi
done

popd > /dev/null

# ***** install log *****

touch ${OPENSHIFT_LOG_DIR}/nohup.log
touch ${OPENSHIFT_LOG_DIR}/nohup_error.log
mkdir ${OPENSHIFT_LOG_DIR}/install

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${install_log}
