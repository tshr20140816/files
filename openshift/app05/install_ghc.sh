#!/bin/bash

set -x

export TZ=JST-9

quota -s
oo-cgroup-read memory.failcnt

ls -lang ${OPENSHIFT_LOG_DIR}

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

export CCACHE_DIR=${OPENSHIFT_DATA_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/ccache
# export CCACHE_LOGFILE=/dev/null
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.$(date +%Y%m%d%H%M%S).log
export CCACHE_MAXSIZE=200M

cd $OPENSHIFT_DATA_DIR

mkdir haskell
cd haskell
[ ! -f network.tar.gz ] && wget -q http://www.accursoft.com/cartridges/network.tar.gz
[ ! -f $OPENSHIFT_DATA_DIR/haskell/usr/bin/cabal ] && tar xfz network.tar.gz

export PATH=$PATH:$OPENSHIFT_DATA_DIR/haskell/usr/bin
export HOME=$OPENSHIFT_DATA_DIR
export OPENSHIFT_HASKELL_DIR=$OPENSHIFT_DATA_DIR/haskell

cabal install --help
ghc-pkg list
ghc-pkg recache

quota -s
oo-cgroup-read memory.failcnt

package_list=()
package_list+=("hashable-1.2.4.0")
package_list+=("unordered-containers-0.2.7.0")
package_list+=("tagged-0.8.3")
package_list+=("semigroups-0.18.1")
package_list+=("random-1.1")
package_list+=("primitive-0.6.1.0")
package_list+=("tf-random-0.5")
package_list+=("QuickCheck-2.8.2")
package_list+=("mtl-2.2.1")
package_list+=("parsec-3.1.9")
package_list+=("regex-base-0.93.2")
# package_list+=("regex-tdfa-1.2.1")
# package_list+=("ShellCheck-0.4.3")

for package in ${package_list[@]}
do
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ${package}"
    if [ $(ghc-pkg list | grep -c ${package}) -ne 0 ]; then
        continue
    fi
    cd ${OPENSHIFT_TMP_DIR}
    rm -f "${package}".tar.gz
    rm -rf "${package}"
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
    if [ $(ghc-pkg list | grep -c ${package}) -eq 0 ]; then
        break
    fi
done

export CC="ccache gcc"
export CXX="ccache g++"

cd ${OPENSHIFT_DATA_DIR}/local/bin
ln -s ccache ${OPENSHIFT_DATA_DIR}/local/bin/gcc
ln -s ccache ${OPENSHIFT_DATA_DIR}/local/bin/g++
ln -s ccache ${OPENSHIFT_DATA_DIR}/local/bin/cc
ln -s ccache ${OPENSHIFT_DATA_DIR}/local/bin/c++

export PATH="${OPENSHIFT_DATA_DIR}/local/bin:$PATH"

ccache -s > ${OPENSHIFT_LOG_DIR}/ccache_stats.txt
ccache -z
ccache -s

package_list=()
package_list+=("regex-tdfa-1.2.1")
package_list+=("ShellCheck-0.4.3")

for package in ${package_list[@]}
do
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ${package}"
    if [ $(ghc-pkg list | grep -c ${package}) -ne 0 ]; then
        continue
    fi
    cd ${OPENSHIFT_TMP_DIR}
    rm -f "${package}".tar.gz
    rm -rf "${package}"
    wget https://hackage.haskell.org/package/"${package}"/"${package}".tar.gz
    tar xfz "${package}".tar.gz
    cd "${package}"
    # cabal install -j1 -v3 --disable-documentation
    cabal install -j1 -v3 --disable-documentation --with-gcc=${OPENSHIFT_DATA_DIR}/local/bin/gcc 2>&1 | tee ${OPENSHIFT_LOG_DIR}/${package}.log
    cd ..
    rm -rf "${package}"
    rm -f "${package}".tar.gz
    quota -s
    oo-cgroup-read memory.failcnt
    if [ $(ghc-pkg list | grep -c ${package}) -eq 0 ]; then
        break
    fi
done

echo "$(date +%Y/%m/%d" "%H:%M:%S) FINISH"
