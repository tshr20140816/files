#!/bin/bash

echo "1015"

set -x

free
sync
cat /proc/sys/vm/drop_caches
echo 1 > /proc/sys/vm/drop_caches
cat /proc/sys/vm/drop_caches
sysctl -w vm.drop_caches=3
free

quota -s
oo-cgroup-read memory.failcnt

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

# tree -a ${OPENSHIFT_DATA_DIR}
# exit

# cat ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings

/usr/bin/gear status --help
/usr/bin/gear start --trace

cd /tmp

ls -lang

rm -rf ghc*

/usr/bin/gear --help

# rm -f monitor_resourse.sh
# wget https://github.com/tshr20140816/files/raw/master/openshift/app01/monitor_resourse.sh
# chmod +x monitor_resourse.sh
# ./monitor_resourse.sh &
# pid=$!

cd $OPENSHIFT_DATA_DIR

mkdir haskell
cd haskell
[ ! -f network.tar.gz ] && wget -q http://www.accursoft.com/cartridges/network.tar.gz
[ ! -f $OPENSHIFT_DATA_DIR/haskell/usr/bin/cabal ] && tar xfz network.tar.gz

export PATH=$PATH:$OPENSHIFT_DATA_DIR/haskell/usr/bin
export HOME=$OPENSHIFT_DATA_DIR
export OPENSHIFT_HASKELL_DIR=$OPENSHIFT_DATA_DIR/haskell

whereis ghc

cabal install --help
ghc-pkg list
ghc-pkg recache
ghc --info

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

for package in ${package_list[@]}
do
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ${package}"
    if [ $(ghc-pkg list | grep -c ${package}) -ne 0 ]; then
        continue
    fi
    cd ${OPENSHIFT_TMP_DIR}
    # rm -f "${package}".tar.gz
    rm -rf "${package}"
    [ ! -f "${package}".tar.gz ]wget https://hackage.haskell.org/package/"${package}"/"${package}".tar.gz
    tar xfz "${package}".tar.gz
    cd "${package}"
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

package_list=()
package_list+=("regex-tdfa-1.2.1")
package_list+=("json-0.9.1")
# package_list+=("directory-1.2.5.1")
# package_list+=("containers-0.5.6.2")
package_list+=("ShellCheck-0.4.3")

for package in ${package_list[@]}
do
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ${package}"
    if [ $(ghc-pkg list | grep -c ${package}) -ne 0 ]; then
        continue
    fi
    # cat ${OPENSHIFT_LOG_DIR}/${package}.log
    cd ${OPENSHIFT_TMP_DIR}
    rm -f "${package}".tar.gz
    rm -rf "${package}"
    wget https://hackage.haskell.org/package/"${package}"/"${package}".tar.gz
    tar xfz "${package}".tar.gz
    cd "${package}"
    # echo "cabal configure --ghc-option=+RTS --ghc-option=-M128m --ghc-option=-RTS -v" | tee ${OPENSHIFT_LOG_DIR}/${package}.log
    # cabal configure --ghc-option=+RTS --ghc-option=-M128m --ghc-option=-RTS -v 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/${package}.log
    echo "cabal install -j1 -v3 --disable-documentation" | tee -a ${OPENSHIFT_LOG_DIR}/${package}.log
    # cabal install -j1 -v3 --disable-documentation --ghc-options="+RTS -N1 -M264m -RTS" 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/${package}.log
    cabal install -j1 -v3 --disable-documentation --ghc-options="+RTS -N1 -M384m -RTS"
    cd ..
    rm -rf "${package}"
    rm -f "${package}".tar.gz
    quota -s
    oo-cgroup-read memory.failcnt
    if [ $(ghc-pkg list | grep -c ${package}) -eq 0 ]; then
        break
    fi
done

# kill ${pid}

echo "FINISH"
