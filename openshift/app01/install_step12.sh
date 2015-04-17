#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** delegate *****

rm -f ${OPENSHIFT_TMP_DIR}/delegate${delegate_version}.tar.gz
rm -rf ${OPENSHIFT_DATA_DIR}/delegate/

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/delegate${delegate_version}.tar.gz ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) delegate tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz delegate${delegate_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/delegate${delegate_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) delegate make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# perl -pi -e 's/^ADMIN = undef$/ADMIN = admin\@rhcloud.local/g' src/Makefile
# TODO CC="ccache gcc"
# ccache gcc -DMKMKMK -DDEFCC=\"ccache gcc\" -I../gen -I../include -O2 -march=native -pipe -fomit-frame-pointer -s -Llib mkmkmk.c -o mkmkmk.exe
# gcc: gcc": No such file or directory
# <command-line>: warning: missing terminating " character
CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s" \
CXXFLAGS="-O2 -march=native -pipe" \
time make -j$(grep -c -e processor /proc/cpuinfo) ADMIN=user@rhcloud.local >${OPENSHIFT_LOG_DIR}/delegate.make.log 2>&1

mkdir ${OPENSHIFT_DATA_DIR}/delegate/
cp src/delegated ${OPENSHIFT_DATA_DIR}/delegate/

mkdir -p ${OPENSHIFT_DATA_DIR}/apache/htdocs/delegate/icons/
# リバースプロキシを経由する際にgifが HTTP 304 とならないことへの対策
cp src/builtin/icons/ysato/*.gif ${OPENSHIFT_DATA_DIR}/apache/htdocs/delegate/icons/
touch ${OPENSHIFT_DATA_DIR}/apache/htdocs/delegate/icons/index.html
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/delegate/ > /dev/null
cat << '__HEREDOC__' > P30080
-P__OPENSHIFT_DIY_IP__:30080
SERVER=http
ADMIN=__ADMIN_MAILADDRESS__
DGROOT=__OPENSHIFT_DATA_DIR__delegate
LOGDIR="__OPENSHIFT_LOG_DIR__"
LOGFILE=${LOGDIR}/delegate_${PORT}.log[date+.%w]
PROTOLOG=${LOGDIR}/delegate_${PORT}.${PROTO}.log[date+.%w]:%X
ERRORLOG=${LOGDIR}/delegate_errors.log[date+.%w]
MOUNT="/mail/* pop://__DELEGATE_POP_SERVER__:110/* noapop"
# MOUNT="/-/builtin/* http://__OPENSHIFT_DIY_IP__:30080/delegate/builtin/*"
FTOCL="/bin/sed -f __OPENSHIFT_DATA_DIR__delegate/filter.txt"
HTTPCONF=methods:GET
HTTPCONF="kill-head:Via,HTTP-VIA,DeleGate-Ver"
DGSIGN="x.x.x/x.x.x"
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' P30080
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' P30080
perl -pi -e 's/__OPENSHIFT_LOG_DIR__/$ENV{OPENSHIFT_LOG_DIR}/g' P30080
redmine_email_address=$(cat ${OPENSHIFT_DATA_DIR}/params/redmine_email_address)
sed -i -e "s|__ADMIN_MAILADDRESS__|${redmine_email_address}|g" P30080
delegate_pop_server=$(cat ${OPENSHIFT_DATA_DIR}/params/delegate_pop_server)
sed -i -e "s|__DELEGATE_POP_SERVER__|${delegate_pop_server}|g" P30080
cat << '__HEREDOC__' > filter.txt
s/http:..__OPENSHIFT_DIY_IP__:30080.-.builtin.icons.ysato/\/delegate\/icons/g
s/<TITLE>/<HTML><HEAD><META HTTP-EQUIV="REFRESH" CONTENT="600"><TITLE>/g
s/<\/TITLE>/<\/TITLE><\/HEAD>/g
s/>V<\/A>/>V<\/A><\/HTML>/g
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' filter.txt
popd > /dev/null

# *** apache conf ***

pushd ${OPENSHIFT_DATA_DIR}/apache/ > /dev/null

cat << '__HEREDOC__' >> conf/custom.conf

# delegate

ProxyRequests Off

<Location /ml>
    SetEnv proxy-initial-not-pooled 1
</Location>

ProxyPass /mail/ http://__OPENSHIFT_DIY_IP__:30080/mail/ retry=1
ProxyPassReverse /mail/ http://__OPENSHIFT_DIY_IP__:30080/mail/
ProxyPass /ml/ http://__OPENSHIFT_DIY_IP__:30080/mail/+pop.__DELEGATE_EMAIL_ACCOUNT__.__DELEGATE_POP_SERVER__/ retry=1
ProxyPassReverse /ml/ http://__OPENSHIFT_DIY_IP__:30080/mail/+pop.__DELEGATE_EMAIL_ACCOUNT__.__DELEGATE_POP_SERVER__/
# ProxyPass /delegate/icons/ http://__OPENSHIFT_DIY_IP__:30080/-/builtin/icons/ysato/
# ProxyPassReverse /delegate/icons/ http://__OPENSHIFT_DIY_IP__:30080/-/builtin/icons/ysato/
ProxyMaxForwards 10

# SetEnvIf Request_URI \/delegate\/icons\/\.+?gif$ GIFFILE
# Header set Last-Modified "Mon, 01 Jan 1990 00:00:00 GMT"
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' conf/custom.conf
delegate_email_account=$(cat ${OPENSHIFT_DATA_DIR}/params/delegate_email_account)
perl -pi -e "s/__DELEGATE_EMAIL_ACCOUNT__/${delegate_email_account}/g" conf/custom.conf
delegate_pop_server=$(cat ${OPENSHIFT_DATA_DIR}/params/delegate_pop_server)
sed -i -e "s|__DELEGATE_POP_SERVER__|${delegate_pop_server}|g" conf/custom.conf

echo "$(date +%Y/%m/%d" "%H:%M:%S) apache configtest" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
./bin/apachectl configtest | tee -a ${OPENSHIFT_LOG_DIR}/install.log

popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm delegate${delegate_version}.tar.gz
rm -rf delegate${delegate_version}
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
