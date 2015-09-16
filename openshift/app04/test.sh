#!/bin/bash

# 1318

set -x

quota -s

# cd /tmp
# rm ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd ${OPENSHIFT_DATA_DIR}/delegate/

cat << '__HEREDOC__' > P33128
-P__OPENSHIFT_DIY_IP__:33128
SERVER=http
ADMIN=dummy@dummy.local
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
# HTTPCONF=cache:any
DGSIGN="x.x.x/x.x.x"
CRON='0 7 * * * -expire 2'
# CMAP="cache:FSV:http:www.yahoo.co.jp"
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_PHP_IP}/g' P33128
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' P33128
perl -pi -e 's/__OPENSHIFT_LOG_DIR__/$ENV{OPENSHIFT_LOG_DIR}/g' P33128

cat P33128

./delegated -r +=P33128

cd /tmp

curl --proxy http://${OPENSHIFT_PHP_IP}:33128 http://www.honda.co.jp/ > /dev/null
curl --proxy http://${OPENSHIFT_PHP_IP}:33128 http://www.mazda.co.jp/ > /dev/null
curl --proxy http://${OPENSHIFT_PHP_IP}:33128 http://www.toyota.co.jp/ > /dev/null
curl --proxy http://${OPENSHIFT_PHP_IP}:33128 http://www.nissan.co.jp/ > /dev/null
curl --proxy http://${OPENSHIFT_PHP_IP}:33128 http://www.subaru.co.jp/ > /dev/null
curl --proxy http://${OPENSHIFT_PHP_IP}:33128 http://www.yahoo.co.jp/ > /dev/null
curl --proxy http://${OPENSHIFT_PHP_IP}:33128 http://www.microsoft.com/ > /dev/null
curl --proxy http://${OPENSHIFT_PHP_IP}:33128 http://www.google.com/ > /dev/null
curl --proxy http://${OPENSHIFT_PHP_IP}:33128 http://www.google.co.jp/ > /dev/null
curl --proxy http://${OPENSHIFT_PHP_IP}:33128 http://headlines.yahoo.co.jp/hl?a=20150916-00010000-fullcount-base
ls -lang

tree ${OPENSHIFT_DATA_DIR}/delegate/cache/

find ${OPENSHIFT_DATA_DIR}/delegate/cache -name '*' -type f -print | grep -v www.honda.co.jp | xargs rm

tree ${OPENSHIFT_DATA_DIR}/delegate/cache/
