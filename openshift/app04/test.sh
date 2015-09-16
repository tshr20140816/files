#!/bin/bash

set -x

quota -s

cd /tmp

rm -rf work

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
HTTPCONF=methods:GET,CONNECT
HTTPCONF="kill-head:Via,HTTP-VIA,DeleGate-Ver"
HTTPCONF=cache:any
DGSIGN="x.x.x/x.x.x"
CRON='0 7 * * * -expire 2'
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_PHP_IP}/g' P33128
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' P33128
perl -pi -e 's/__OPENSHIFT_LOG_DIR__/$ENV{OPENSHIFT_LOG_DIR}/g' P33128

cat P33128

./delegate -r +=P33128

cd /tmp

curl --proxy http://${OPENSHIFT_PHP_IP}:33128 http://www.yahoo.co.jp/ > /dev/null

ls -lang

tree ${OPENSHIFT_DATA_DIR}/delegate/cache/
