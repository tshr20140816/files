#!/bin/bash

set -x

export TZ=JST-9

quota -s
oo-cgroup-read memory.failcnt

cd $OPENSHIFT_DATA_DIR

mkdir haskell
cd haskell
[ ! -f network.tar.gz ] && wget -q http://www.accursoft.com/cartridges/network.tar.gz
[ ! -f $OPENSHIFT_DATA_DIR/haskell/usr/bin/cabal ] && tar xfz network.tar.gz

export PATH=$PATH:$OPENSHIFT_DATA_DIR/haskell/usr/bin
export HOME=$OPENSHIFT_DATA_DIR
export OPENSHIFT_HASKELL_DIR=$OPENSHIFT_DATA_DIR/haskell

ghc-pkg list
ghc-pkg recache

quota -s
oo-cgroup-read memory.failcnt

package_list=()
package_list+=("hashable-1.2.4.0")
package_list+=("unordered-containers-0.2.7.0")
package_list+=("tagged-0.8.3")
package_list+=("semigroups-0.18.1")

for package in ${package_list[@]}
do
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ${package}"
    if [ $(ghc-pkg list | grep -c ${package}) -ne 0 ]; then
        continue
    fi
    cd ${OPENSHIFT_TMP_DIR}
    rm -f "${package}".tar.gz
    wget https://hackage.haskell.org/package/"${package}"/"${package}".tar.gz
    tar xfz "${package}".tar.gz
    cd "${package}"
    # cabal install -j1 -v3 --disable-documentation
    cabal install -j2 --disable-documentation
    cd ..
    rm -rf "${package}"
    rm -f "${package}".tar.gz
    quota -s
    oo-cgroup-read memory.failcnt
done

echo "$(date +%Y/%m/%d" "%H:%M:%S) FINISH"
