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

ls -lang

rm -f *.tar.gz

cd $OPENSHIFT_DATA_DIR

rm -rf ccache
rm -f compiler.jar

tree .ghc

rm -rf apache

ls -lang

# wget -q http://www.accursoft.com/cartridges/network.tar.gz
# wget -q http://www.accursoft.com/cartridges/yesod.tar.gz
# wget -q http://www.accursoft.com/cartridges/snap.tar.gz
# wget -q http://www.accursoft.com/cartridges/happstack.tar.gz
# wget -q http://www.accursoft.com/cartridges/mflow.tar.gz
# wget -q http://www.accursoft.com/cartridges/scotty.tar.gz

# ls -lang
