#!/bin/bash

echo "0850"

# set -x

quota -s
oo-cgroup-read memory.failcnt

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

/usr/bin/gear status cron-1.4
/usr/bin/gear status php-5.4
/usr/bin/gear start --trace

cd /tmp

ls -lang

/usr/bin/gear --help

export PATH=$PATH:$OPENSHIFT_DATA_DIR/haskell/usr/bin
export HOME=$OPENSHIFT_DATA_DIR
export OPENSHIFT_HASKELL_DIR=$OPENSHIFT_DATA_DIR/haskell

# cabal configure --ghc-option=+RTS --ghc-option=-M128m --ghc-option=-RTS -v
ghc --help
ghc --info

cd ${OPENSHIFT_TMP_DIR}

cd $OPENSHIFT_DATA_DIR

rm -rf .cabal
rm -rf .ghc

ls -lang

echo "FINISH"

