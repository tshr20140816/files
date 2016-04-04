#!/bin/bash

echo "0220"

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

# mkdir 20160405

cd 20160405

# rm -rf scotty.tar.gz
# [ ! -f scotty.tar.gz ] && wget http://www.accursoft.com/cartridges/scotty.tar.gz
# ls -lang scotty.tar.gz

# tar xvfz scotty.tar.gz

# tree ./

rm -rf /tmp/20160405/usr/lib/ghc-7.10.3/package.conf.d/

ls -lang usr/bin

export OPENSHIFT_HASKELL_DIR=/tmp/20160405/

# usr/bin/ghc --help
# usr/bin/ghc --version

tree ${OPENSHIFT_DATA_DIR}

export PATH=/tmp/20160405/usr/bin:$PATH
export HOME=${OPENSHIFT_DATA_DIR}

usr/bin/cabal --help
# usr/bin/cabal --version
# usr/bin/cabal update
usr/bin/cabal install shellcheck

# ls -lang /tmp/20160405/usr/lib/ghc-7.10.3/package.conf.d/

tree ./

quota -s

exit
