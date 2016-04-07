#!/bin/bash

echo "1016"

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

rm -rf .ghc

ls -lang

mkdir haskell
cd haskell

[ ! -f network.tar.gz ] && wget -q http://www.accursoft.com/cartridges/network.tar.gz
# wget -q http://www.accursoft.com/cartridges/yesod.tar.gz
# wget -q http://www.accursoft.com/cartridges/snap.tar.gz
# wget -q http://www.accursoft.com/cartridges/happstack.tar.gz
# wget -q http://www.accursoft.com/cartridges/mflow.tar.gz
# wget -q http://www.accursoft.com/cartridges/scotty.tar.gz

[ ! -f $OPENSHIFT_DATA_DIR/haskell/usr/bin/cabal ] && tar xfz network.tar.gz

ls -lang
ls -lang usr/bin
ls -lang bin

export PATH=$PATH:$OPENSHIFT_DATA_DIR/haskell/usr/bin
export HOME=$OPENSHIFT_DATA_DIR
export OPENSHIFT_HASKELL_DIR=$OPENSHIFT_DATA_DIR/haksell

cat $HOME/.cabal/config

ghc --version

cabal update --help
cabal -v3 update
cabal install --help
cabal install -j1 -v3 --disable-documentation shellcheck

echo "FINISH"

