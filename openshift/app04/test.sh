#!/bin/bash

echo "0342"

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

rm -rf ${OPENSHIFT_DATA_DIR}/.cabal/

rm -rf 20160405
mkdir 20160405
cd 20160405

# rm -rf scotty.tar.gz
[ ! -f scotty.tar.gz ] && wget -q http://www.accursoft.com/cartridges/scotty.tar.gz
# ls -lang scotty.tar.gz

tar xfz scotty.tar.gz

# tree ./

# rm -rf /tmp/20160405/usr/lib/ghc-7.10.3/package.conf.d/

ls -lang usr/bin

export OPENSHIFT_HASKELL_DIR=/tmp/20160405/

# usr/bin/ghc --help
# usr/bin/ghc --version

# tree ${OPENSHIFT_DATA_DIR}

# cat ${OPENSHIFT_DATA_DIR}/.cabal/config

export PATH=/tmp/20160405/usr/bin:$PATH
export HOME=${OPENSHIFT_DATA_DIR}

# mkdir /tmp/20160405/usr/lib/ghc-7.10.3/package.conf.d
# usr/bin/ghc-pkg --help
# usr/bin/ghc-pkg --user recache
# usr/bin/ghc-pkg recache

# usr/bin/cabal --help
# usr/bin/cabal --version
usr/bin/cabal update
ls -lang /tmp/20160405/usr/lib/ghc-7.10.3/package.conf.d/
usr/bin/ghc-pkg --global recache
ls -lang /tmp/20160405/usr/lib/ghc-7.10.3/package.conf.d/
usr/bin/ghc-pkg list
set -x
usr/bin/cabal install shellcheck
usr/bin/ghc-pkg list

# ls -lang /tmp/20160405/usr/lib/ghc-7.10.3/package.conf.d/

# tree ./

tree ${OPENSHIFT_DATA_DIR}/.cabal/

find / -name shellcheck -print 2>/dev/null

quota -s

exit
