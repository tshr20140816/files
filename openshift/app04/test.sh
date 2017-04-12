#!/bin/bash

echo "0921"

set -x

quota -s
oo-cgroup-read memory.failcnt
echo "$(oo-cgroup-read memory.usage_in_bytes)" | awk '{printf "%\047d\n", $0}'

# oo-cgroup-read all
# oo-cgroup-read report

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

/usr/bin/gear start --trace

ls -lang ${OPENSHIFT_TMP_DIR}
ls -lang ${OPENSHIFT_DATA_DIR}
ls -lang ${OPENSHIFT_REPO_DIR}

quota -s

# curl http://ranking.rakuten.co.jp/daily/?nrw=1\&stx=itunes\&prl=\&pru=\&rvf=\&arf=
curl -s http://ranking.rakuten.co.jp/daily/?nrw=1\&stx=itunes\&prl=\&pru=\&rvf=\&arf= | grep -o 'rnkRanking_dispRank_overHundred.+'
curl -s http://ranking.rakuten.co.jp/daily/?nrw=1\&stx=itunes\&prl=\&pru=\&rvf=\&arf= | grep 'rnkRanking_dispRank_overHundred'
curl -s http://ranking.rakuten.co.jp/daily/?nrw=1\&stx=itunes\&prl=\&pru=\&rvf=\&arf= | grep 'rnkRanking_dispRank_overHundred' | grep -o '\[0-9]+'
curl -s http://ranking.rakuten.co.jp/daily/?nrw=1\&stx=itunes\&prl=\&pru=\&rvf=\&arf= | grep 'rnkRanking_dispRank_overHundred' | grep -o \[0-9]+
# curl http://ranking.rakuten.co.jp/daily/?nrw=1\&stx=itunes\&prl=\&pru=\&rvf=\&arf= | grep 'rnkRanking_dispRank_overHundred' | sed 's/<.+?>//'

quota -s
echo "FINISH"
exit
