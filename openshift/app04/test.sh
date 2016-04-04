#!/bin/bash

echo "0147"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang

# mkdir 20160405

cd 20160405

# rm -rf scotty.tar.gz
# [ ! -f scotty.tar.gz ] && wget http://www.accursoft.com/cartridges/scotty.tar.gz
# ls -lang scotty.tar.gz

# tar xvfz scotty.tar.gz

tree ./

ls -lang usr/bin

cat usr/bin/ghc

export OPENSHIFT_HASKELL_DIR=/tmp/20160405/

set -x

# usr/bin/ghc --help
# usr/bin/ghc --version

usr/bin/cabal --help
usr/bin/cabal --version
usr/bin/cabal update

quota -s

exit
