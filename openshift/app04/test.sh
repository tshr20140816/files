#!/bin/bash

echo "0000"

# set -x

quota -s

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

rm -rf ${OPENSHIFT_DATA_DIR}/.cabal/
rm -rf 20160405

ls -lang

wget -q http://www.accursoft.com/cartridges/network.tar.gz
wget -q http://www.accursoft.com/cartridges/yesod.tar.gz
wget -q http://www.accursoft.com/cartridges/snap.tar.gz
wget -q http://www.accursoft.com/cartridges/happstack.tar.gz
wget -q http://www.accursoft.com/cartridges/mflow.tar.gz
wget -q http://www.accursoft.com/cartridges/scotty.tar.gz

ls -lang
