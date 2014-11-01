#!/bin/bash

set -x

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 12 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** delegate *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/delegate${delegate_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` delegate tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz delegate${delegate_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/delegate${delegate_version} > /dev/null
echo `date +%Y/%m/%d" "%H:%M:%S` delegate make >> ${OPENSHIFT_LOG_DIR}/install.log
perl -pi -e 's/^ADMIN = undef$/ADMIN = admin\@rhcloud.local/g' src/Makefile
time make -j2 CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" 2>&1 | tee ${OPENSHIFT_LOG_DIR}/delegate.make.log
mkdir ${OPENSHIFT_DATA_DIR}/delegate/
cp src/delegated ${OPENSHIFT_DATA_DIR}/delegate/
# cp ${OPENSHIFT_DATA_DIR}/github/openshift/delegated.xz ./
# xz -dv delegated.xz
# mv ./delegated ${OPENSHIFT_DATA_DIR}/delegate/

# apache htdocs
mkdir -p ${OPENSHIFT_DATA_DIR}/apache/htdocs/delegate/icons
cp src/builtin/icons/ysato/*.* ${OPENSHIFT_DATA_DIR}/apache/htdocs/delegate/icons/
# */
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/delegate/ > /dev/null
cat << '__HEREDOC__' > P30080
-P__OPENSHIFT_DIY_IP__:30080
SERVER=http
ADMIN=__ADMIN_MAILADDRESS__
DGROOT=__OPENSHIFT_DATA_DIR__delegate
# LOGDIR="__OPENSHIFT_LOG_DIR__"
MOUNT="/mail/* pop://pop.mail.yahoo.co.jp:110/* noapop"
# MOUNT="/-/builtin/* http://__OPENSHIFT_DIY_IP__:30080/delegate/builtin/*"
FTOCL="/bin/sed -f __OPENSHIFT_DATA_DIR__delegate/filter.txt"
HTTPCONF=methods:GET,HEAD
HTTPCONF="kill-head:Via,HTTP-VIA,DeleGate-Ver"
DGSIGN="x.x.x/x.x.x"
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' P30080
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' P30080
perl -pi -e 's/__OPENSHIFT_LOG_DIR__/$ENV{OPENSHIFT_LOG_DIR}/g' P30080
redmine_email_address=`cat ${OPENSHIFT_DATA_DIR}redmine_email_address`
sed -i -e "s|__ADMIN_MAILADDRESS__|${redmine_email_address}|g" P30080
cat << '__HEREDOC__' > filter.txt
s/http:..__OPENSHIFT_DIY_IP__:30080.-.builtin.icons.ysato/\/delegate\/icons/g
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' filter.txt
popd > /dev/null

# *** apache conf ***

pushd ${OPENSHIFT_DATA_DIR}/apache/ > /dev/null

cat << '__HEREDOC__' >> conf/custom.conf

# delegate

ProxyRequests Off
ProxyPass /mail/ http://__OPENSHIFT_DIY_IP__:30080/mail/
ProxyPassReverse /mail/ http://__OPENSHIFT_DIY_IP__:30080/mail/
ProxyPass /ml/ http://__OPENSHIFT_DIY_IP__:30080/mail/+__DELEGATE_MAIL_ALIAS__/
ProxyPassReverse /ml/ http://__OPENSHIFT_DIY_IP__:30080/mail/+__DELEGATE_MAIL_ALIAS__/
ProxyMaxForwards 10
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' conf/custom.conf
delegate_mail_alias=`cat ${OPENSHIFT_DATA_DIR}/delegate_mail_alias`
perl -pi -e "s/__DELEGATE_MAIL_ALIAS__/${delegate_mail_alias}/g" conf/custom.conf
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm delegate${delegate_version}.tar.gz
rm -rf delegate${delegate_version}
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 12 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
