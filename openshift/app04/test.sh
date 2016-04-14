#!/bin/bash

echo "1726"

set -x

quota -s
oo-cgroup-read memory.failcnt

# oo-cgroup-read all
# oo-cgroup-read report

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

# tree -a ${OPENSHIFT_DATA_DIR}
# exit

/usr/bin/gear start --trace

# shopt

cd /tmp

ls -lang

rm -f  $OPENSHIFT_DATA_DIR/index.html

ls -lang $OPENSHIFT_DATA_DIR

wget -q http://www.accursoft.com/cartridges/network.tar.gz
wget -q http://www.accursoft.com/cartridges/yesod.tar.gz
wget -q http://www.accursoft.com/cartridges/snap.tar.gz
wget -q http://www.accursoft.com/cartridges/happstack.tar.gz
wget -q http://www.accursoft.com/cartridges/mflow.tar.gz
wget -q http://www.accursoft.com/cartridges/scotty.tar.gz

ls -lang

rm -f *.gz

quota -s

echo "FINISH"
