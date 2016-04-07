#!/bin/bash

echo "0825"

# set -x

quota -s
oo-cgroup-read memory.failcnt

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

/usr/bin/gear status
/usr/bin/gear start --trace

cd /tmp

ls -lang

/usr/bin/gear --help

export PATH=$PATH:$OPENSHIFT_DATA_DIR/haskell/usr/bin
export HOME=$OPENSHIFT_DATA_DIR
export OPENSHIFT_HASKELL_DIR=$OPENSHIFT_DATA_DIR/haskell

cabal configure --ghc-option=+RTS --ghc-option=-M128m --ghc-option=-RTS -v

rm -f *.gz

exit

cd ${OPENSHIFT_TMP_DIR}

if [ ! -f ${OPENSHIFT_DATA_DIR}/local/bin/ccache ]; then
    rm -f ccache-3.2.4.tar.xz
    rm -rf ccache-3.2.4
    wget http://samba.org/ftp/ccache/ccache-3.2.4.tar.xz
    tar Jxf ccache-3.2.4.tar.xz
    cd ccache-3.2.4
    ./configure --prefix=${OPENSHIFT_DATA_DIR}/local
    time make -j1
    make install
    cd ..
    rm -rf ccache-3.2.4
    rm -f ccache-3.2.4.tar.xz
fi

cd $OPENSHIFT_DATA_DIR

# rm -rf .ghc
# tree -a .ghc

# ls -lang

mkdir haskell
cd haskell

[ ! -f network.tar.gz ] && wget -q http://www.accursoft.com/cartridges/network.tar.gz
# wget -q http://www.accursoft.com/cartridges/yesod.tar.gz
# wget -q http://www.accursoft.com/cartridges/snap.tar.gz
# wget -q http://www.accursoft.com/cartridges/happstack.tar.gz
# wget -q http://www.accursoft.com/cartridges/mflow.tar.gz
# wget -q http://www.accursoft.com/cartridges/scotty.tar.gz

[ ! -f $OPENSHIFT_DATA_DIR/haskell/usr/bin/cabal ] && tar xfz network.tar.gz

# ls -lang
ls -lang usr/bin
# ls -lang bin

export PATH=$PATH:$OPENSHIFT_DATA_DIR/haskell/usr/bin
export HOME=$OPENSHIFT_DATA_DIR
export OPENSHIFT_HASKELL_DIR=$OPENSHIFT_DATA_DIR/haskell
# export GHCRTS='-M128M'

# cat $HOME/.cabal/config

# ghc --version
# ghc-pkg --help
ghc-pkg list
# ghc-pkg -v2 dump
# ghc-pkg --global -v2 recache
# ghc-pkg --user -v2 recache
# tree --help
# tree -a $OPENSHIFT_DATA_DIR
# cabal update --help
# cabal -v3 update
# cabal update
# cabal install --help
# cabal install -j1 -v3 --disable-documentation shellcheck
# cabal install -j1 -v3 --disable-documentation virthualenv

# https://hackage.haskell.org/package/

echo "FINISH"

