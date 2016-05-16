#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** delegate *****

rm -f ${OPENSHIFT_TMP_DIR}/delegate${delegate_version}.tar.gz
rm -rf ${OPENSHIFT_DATA_DIR}/delegate/

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    file_name=${OPENSHIFT_APP_UUID}_maked_delegate${delegate_version}.tar.xz
    url=$(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    while :
    do
        if [ $(wget -nv --spider --timeout 60 -t 1 ${url} 2>&1 | grep -c '200 OK') -eq 1 ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) delegate maked wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            break
        else
            echo "$(date +%Y/%m/%d" "%H:%M:%S) delegate maked waiting" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            sleep 10s
        fi
    done
    wget $(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    echo "$(date +%Y/%m/%d" "%H:%M:%S) delegate maked tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar Jxf ${file_name}
    rm -f ${file_name}
else
    cp ${OPENSHIFT_DATA_DIR}/download_files/delegate${delegate_version}.tar.gz ./
    echo "$(date +%Y/%m/%d" "%H:%M:%S) delegate tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar zxf delegate${delegate_version}.tar.gz
fi
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/delegate${delegate_version} > /dev/null
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    :
else
    echo "$(date +%Y/%m/%d" "%H:%M:%S) delegate make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

    time make -j$(grep -c -e processor /proc/cpuinfo) \
     ADMIN=user@rhcloud.local \
     > ${OPENSHIFT_LOG_DIR}/delegate.make.log 2>&1
    mv ${OPENSHIFT_LOG_DIR}/install_delegate.log ${OPENSHIFT_LOG_DIR}/install/
fi

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
MAXIMA="delegated:5"
MOUNT="/mail/* pop://__DELEGATE_POP_SERVER__:110/* noapop"
# MOUNT="/-/builtin/* http://__OPENSHIFT_DIY_IP__:30080/delegate/builtin/*"
FTOCL="/bin/sed -f __OPENSHIFT_DATA_DIR__delegate/filter.txt"
HTTPCONF="methods:GET"
HTTPCONF="kill-head:Via,HTTP-VIA,DeleGate-Ver"
HTTPCONF="kill-rhead:X-Request*"
DGSIGN="x.x.x/x.x.x"
# CONNECT="direct:*:*:*"
# REACHABLE="__DELEGATE_POP_SERVER__"
# REMITTABLE="http,pop"
# RESOLV="cache,dns"
# CACHE=no
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
cat << '__HEREDOC__' > filter.txt
s/http:..__OPENSHIFT_DIY_IP__:30080.-.builtin.icons.ysato/\/delegate\/icons/g
s/<TITLE>/<HTML><HEAD><META HTTP-EQUIV="REFRESH" CONTENT="600"><TITLE>/g
s/<\/TITLE>/<\/TITLE><\/HEAD>/g
s/<FORM ACTION="..\/-search" METHOD=GET>.+?<\/FORM>//g
s/<TABLE width=100% border=0 bgcolor=#8080FF cellpadding=1 cellspacing=0>.*/<\/HTML>/g
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' filter.txt &

cat << '__HEREDOC__' > P33128
-P__OPENSHIFT_DIY_IP__:33128
SERVER=http
ADMIN=__ADMIN_MAILADDRESS__
DGROOT=__OPENSHIFT_DATA_DIR__delegate
LOGDIR="__OPENSHIFT_LOG_DIR__"
LOGFILE=${LOGDIR}/delegate_${PORT}.log[date+.%w]
PROTOLOG=${LOGDIR}/delegate_${PORT}.${PROTO}.log[date+.%w]:%X
ERRORLOG=${LOGDIR}/delegate_errors.log[date+.%w]
CACHEDIR=__OPENSHIFT_DATA_DIR__delegate/cache
CACHE=do
MAXIMA=delegated:10
REMITTABLE=http,ftp,https
HTTPCONF=methods:GET,CONNECT
HTTPCONF="kill-head:Via,HTTP-VIA,DeleGate-Ver"
HTTPCONF=cache:any
DGSIGN="x.x.x/x.x.x"
CRON='0 7 * * * -expire 2'
RESOLV="cache,dns"
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' P33128
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' P33128
perl -pi -e 's/__OPENSHIFT_LOG_DIR__/$ENV{OPENSHIFT_LOG_DIR}/g' P33128
redmine_email_address=$(cat ${OPENSHIFT_DATA_DIR}/params/redmine_email_address)
sed -i -e "s|__ADMIN_MAILADDRESS__|${redmine_email_address}|g" P33128
popd > /dev/null

cp ${OPENSHIFT_DATA_DIR}/delegate/P30080 ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/
cp ${OPENSHIFT_DATA_DIR}/delegate/filter.txt ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/
cp ${OPENSHIFT_DATA_DIR}/delegate/P33128 ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/

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
./bin/apachectl configtest | tee -a ${OPENSHIFT_LOG_DIR}/install.log &

popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm delegate${delegate_version}.tar.gz &
rm -rf delegate${delegate_version}
popd > /dev/null

wait

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
