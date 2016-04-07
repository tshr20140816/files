#!/bin/bash

echo "1654"

set -x

quota -s

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang

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

if [ $(ghc-pkg list | grep -c hashable) -eq 0 ]; then
    cd /tmp
    rm -rf hashable
    git clone https://github.com/tibbe/hashable.git
    cd hashable
    cabal install -j1 -v3 --disable-documentation
fi

if [ $(ghc-pkg list | grep -c unordered-containers) -eq 0 ]; then
    cd /tmp
    rm -rf unordered-containers
    git clone https://github.com/tibbe/unordered-containers.git
    cd unordered-containers
    cabal install -j1 -v3 --disable-documentation
fi

if [ $(ghc-pkg list | grep -c tagged) -eq 0 ]; then
    cd /tmp
    rm -rf tagged
    git clone https://github.com/ekmett/tagged.git
    cd tagged
    cabal install -j1 -v3 --disable-documentation
fi

if [ $(ghc-pkg list | grep -c semigroups) -eq 0 ]; then
    cd /tmp
    rm -rf semigroups
    git clone https://github.com/ekmett/semigroups.git
    cd semigroups
    cabal install -j1 -v3 --disable-documentation
fi

if [ $(ghc-pkg list | grep -c random) -eq 0 ]; then
    cd /tmp
    rm -rf random
    git clone http://git.haskell.org/packages/random.git
    cd random
    cabal install -j1 -v3 --disable-documentation
fi

if [ $(ghc-pkg list | grep -c tf-random) -eq 0 ]; then
    cd /tmp
    rm -f tf-random.zip
    rm -rf tf-random
    wget --content-disposition http://hub.darcs.net/michal.palka/tf-random/dist
    unzip tf-random.zip
    cd tf-random
    cabal install -j1 -v3 --disable-documentation
fi

echo "DUMMY"
exit

if [ $(ghc-pkg list | grep -c quickcheck) -eq 0 ]; then
    cd /tmp
    rm -rf quickcheck
    git clone https://github.com/nick8325/quickcheck.git
    cd quickcheck
    cabal install -j1 -v3 --disable-documentation
fi

echo "DUMMY"
exit

cd /tmp
rm -rf shellcheck
git clone https://github.com/koalaman/shellcheck.git
cd shellcheck
cabal install -j1 -v3 --disable-documentation

echo "FINISH"

