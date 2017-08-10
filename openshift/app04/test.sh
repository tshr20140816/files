#!/bin/bash

echo "1408"

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

cd /tmp

openssl -help
openssl ecparam -help
openssl ec -help
openssl ecparam -out private_key.pem -name prime256v1 -genkey
openssl ec -pubout -in private_key.pem -out public_key.pem

cat private_key.pem
cat public_key.pem

rm -f private_key.pem
rm -f public_key.pem

quota -s
echo "FINISH"
exit
