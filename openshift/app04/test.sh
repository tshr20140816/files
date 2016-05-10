#!/bin/bash

echo "1129"

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

cd /tmp
ls -lang
cd $OPENSHIFT_DATA_DIR
ls -lang

quota -s

# -----

cd /tmp
rm -rf 20160506
rm -rf 20160509
# rm -rf gomi build
# rm -rf ${OPENSHIFT_DATA_DIR}/usr
cd ${OPENSHIFT_REPO_DIR}
rm -f 502.php file_list.zip

# -----

cd /tmp

mv d1.txt d3.txt
mv d2.txt d4.txt
ls -lang



ls -lang ${OPENSHIFT_REPO_DIR}

cd /tmp

ssh-keygen -t rsa -f id_rsa -P ''
chmod 600 id_rsa
chmod 600 id_rsa.pub

echo 'hoge' | openssl rsautl -encrypt -inkey ./id_rsa > pass.rsa
openssl rsautl -decrypt -inkey ./id_rsa -in pass.rsa

quota -s
echo "FINISH"
exit
