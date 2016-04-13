#!/bin/bash

# cd /tmp
# wget https://github.com/tshr20140816/files/raw/master/openshift/app05/install_ghc.sh
# bash install_ghc.sh > $OPENSHIFT_REPO_DIR/diy/install.txt 2>&1 &

set -x

export TZ=JST-9

quota -s
oo-cgroup-read memory.failcnt

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

ls -lang ${OPENSHIFT_LOG_DIR}

cd $OPENSHIFT_DATA_DIR

mkdir tmp

[ ! -f gmp-4.3.1-7.el6_2.2.x86_64.rpm ] && wget http://mirror.centos.org/centos/6/os/x86_64/Packages/gmp-4.3.1-7.el6_2.2.x86_64.rpm
rpm2cpio gmp-4.3.1-7.el6_2.2.x86_64.rpm | cpio -idmv
rm -f gmp-4.3.1-7.el6_2.2.x86_64.rpm
cd usr/lib64
ln -s libgmp.so.3 libgmp.so
export LD_LIBRARY_PATH=$OPENSHIFT_DATA_DIR/usr/lib64

cd $OPENSHIFT_DATA_DIR
mkdir haskell
cd haskell
[ ! -f network.tar.gz ] && wget -q http://www.accursoft.com/cartridges/network.tar.gz
[ ! -f $OPENSHIFT_DATA_DIR/haskell/usr/bin/cabal ] && tar xfz network.tar.gz

quota -s
oo-cgroup-read memory.failcnt

export PATH=$PATH:$OPENSHIFT_DATA_DIR/haskell/usr/bin
export HOME=$OPENSHIFT_DATA_DIR
export OPENSHIFT_HASKELL_DIR=$OPENSHIFT_DATA_DIR/haskell

cabal install --help
ghc-pkg list
ghc-pkg recache

quota -s
oo-cgroup-read memory.failcnt

mv -f ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings.org ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings

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

for package in "${package_list[@]}"
do
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ${package}"
    if [ $(ghc-pkg list | grep -c ${package}) -ne 0 ]; then
        continue
    fi
    cd ${OPENSHIFT_DATA_DIR}/tmp
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

mkdir -p ${OPENSHIFT_DATA_DIR}/local/bin
cd ${OPENSHIFT_DATA_DIR}/local/bin
cat << '__HEREDOC__' > gcc
#!/bin/bash

export TZ=JST-9

while :
do
    dt=$(date +%H%M%S)
    usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
    usage_in_bytes_format=$(echo "${usage_in_bytes}" | awk '{printf "%\047d\n", $0}')
    failcnt=$(oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $0}')
    echo "$dt $usage_in_bytes_format $failcnt"
    if [ "${usage_in_bytes}" -lt 450000000 ]; then
        break
    fi
    # ps alx --sort -rss | head -n 3
    if [ "${usage_in_bytes}" -gt 500000000 ]; then
        pushd ${OPENSHIFT_TMP_DIR} > /dev/null
        wget -q http://mirrors.kernel.org/gnu/gcc/gcc-4.9.3/gcc-4.9.3.tar.bz2
        rm -f gcc-4.9.3.tar.bz2
        popd > /dev/null
    fi
    sleep 60s
done

set -x
/usr/bin/gcc "$@"
__HEREDOC__
chmod +x ${OPENSHIFT_DATA_DIR}/local/bin/gcc

export PATH="${OPENSHIFT_DATA_DIR}/local/bin:$PATH"

if [ ! -f ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings.org ]; then
    cp ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings.org
    sed -i -e "s|/usr/bin/gcc|${OPENSHIFT_DATA_DIR}/local/bin/gcc|g" ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings
fi

cat ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings

package_list=()
package_list+=("regex-tdfa-1.2.1")
package_list+=("json-0.9.1")
# package_list+=("directory-1.2.5.1")
# package_list+=("containers-0.5.6.2")
package_list+=("ShellCheck-0.4.3")

for package in "${package_list[@]}"
do
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ${package}"
    if [ $(ghc-pkg list | grep -c ${package}) -ne 0 ]; then
        continue
    fi
    oo-cgroup-read memory.usage_in_bytes
    cd ${OPENSHIFT_DATA_DIR}/tmp
    rm -f "${package}".tar.gz
    rm -rf "${package}"
    wget https://hackage.haskell.org/package/"${package}"/"${package}".tar.gz
    tar xfz "${package}".tar.gz
    cd "${package}"
    # cabal install -j1 -v3 --disable-documentation
    cabal install -j1 -v3 --disable-optimization --disable-documentation \
     --disable-tests --disable-coverage --disable-benchmarks \
     --ghc-options="+RTS -N1 -M448m -RTS" 2>&1 | tee ${OPENSHIFT_LOG_DIR}/${package}.log
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
