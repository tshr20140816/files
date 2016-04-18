#!/bin/bash

# cd /tmp
# wget https://github.com/tshr20140816/files/raw/master/openshift/app05/install_ghc.sh
# bash install_ghc.sh > $OPENSHIFT_LOG_DIR/install.txt 2>&1 &

set -x

export TZ=JST-9

# quota -s
# oo-cgroup-read memory.failcnt

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

ls -lang ${OPENSHIFT_LOG_DIR}
mkdir ${OPENSHIFT_DATA_DIR}/tmp
pushd ${OPENSHIFT_DATA_DIR} > /dev/null
wget -nc http://mirror.centos.org/centos/6/os/x86_64/Packages/gmp-4.3.1-7.el6_2.2.x86_64.rpm
rpm2cpio gmp-4.3.1-7.el6_2.2.x86_64.rpm | cpio -idmv
rm -f gmp-4.3.1-7.el6_2.2.x86_64.rpm
popd > /dev/null
pushd ${OPENSHIFT_DATA_DIR}/usr/lib64 > /dev/null
ln -s libgmp.so.3 libgmp.so
popd > /dev/null
mkdir ${OPENSHIFT_DATA_DIR}/haskell
pushd ${OPENSHIFT_DATA_DIR}/haskell > /dev/null
if [ ! -f ${OPENSHIFT_DATA_DIR}/haskell/usr/bin/cabal ]; then
    wget -nc -q http://www.accursoft.com/cartridges/network.tar.gz
    tar xfz network.tar.gz
fi
rm -f network.tar.gz
popd > /dev/null

# quota -s
# oo-cgroup-read memory.failcnt

export LD_LIBRARY_PATH=${OPENSHIFT_DATA_DIR}/usr/lib64
export PATH=${PATH}:${OPENSHIFT_DATA_DIR}/haskell/usr/bin
export HOME=${OPENSHIFT_DATA_DIR}
export OPENSHIFT_HASKELL_DIR=${OPENSHIFT_DATA_DIR}/haskell

# cabal install --help
# ghc-pkg list
ghc-pkg recache

# quota -s
# oo-cgroup-read memory.failcnt

mkdir -p ${OPENSHIFT_DATA_DIR}/local/bin
cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/local/bin/gcc
#!/bin/bash

while :
do
    dt=$(date +%H%M%S)
    usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
    usage_in_bytes_format=$(echo "${usage_in_bytes}" | awk '{printf "%\047d\n", $0}')
    failcnt=$(oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $0}')
    echo "$dt $usage_in_bytes_format $failcnt"
    if [ "${usage_in_bytes}" -lt 500000000 ]; then
        break
    fi
    # ps alx --sort -rss | head -n 3
    if [ "${usage_in_bytes}" -gt 500000000 ]; then
        pushd ${OPENSHIFT_TMP_DIR} > /dev/null
        # sumanu
        wget -q http://mirrors.kernel.org/gnu/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2
        rm -f gcc-5.3.0.tar.bz2
        popd > /dev/null
    fi
    sleep 60s
done

set -x
/usr/bin/gcc "$@"
__HEREDOC__
chmod +x ${OPENSHIFT_DATA_DIR}/local/bin/gcc

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
package_list+=("regex-tdfa-1.2.1")
package_list+=("json-0.9.1")
package_list+=("ShellCheck-0.4.3")

for package in "${package_list[@]}"
do
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ${package}"
    [ $(ghc-pkg list | grep -c ${package}) -ne 0 ] && continue
    pushd ${OPENSHIFT_DATA_DIR}/tmp > /dev/null
    rm -rf "${package}"
    wget -nc -q https://hackage.haskell.org/package/"${package}"/"${package}".tar.gz
    tar xfz "${package}".tar.gz
    pushd "${package}" > /dev/null
    if [ "${package}" != "regex-tdfa-1.2.1" ]; then
        cabal install -j2 --disable-documentation -O2 \
         --enable-split-objs --disable-library-for-ghci --enable-executable-stripping --enable-library-stripping \
         --disable-tests --disable-coverage --disable-benchmarks
    else
        PATH_ORG="${PATH}"
        export PATH="${OPENSHIFT_DATA_DIR}/local/bin:${PATH}"
        if [ ! -f ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings.org ]; then
            cp ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings.org
            sed -i -e "s|/usr/bin/gcc|${OPENSHIFT_DATA_DIR}/local/bin/gcc|g" ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings
        fi
        # cat ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings
        cabal install -j1 -v3 --disable-optimization --disable-documentation \
         --disable-tests --disable-coverage --disable-benchmarks --disable-library-for-ghci \
         --ghc-options="+RTS -N1 -M448m -RTS"
        export PATH="${PATH_ORG}"
        cp -f ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings.org ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings
    fi
    popd > /dev/null
    rm -rf "${package}"
    rm -f "${package}".tar.gz
    popd > /dev/null
    # quota -s
    # oo-cgroup-read memory.failcnt
    [ $(ghc-pkg list | grep -c ${package}) -eq 0 ] && break
done

if [ ! -f ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings.org ]; then
    cp ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings.org
    sed -i -e "s|/usr/bin/gcc|${OPENSHIFT_DATA_DIR}/local/bin/gcc|g" ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings
fi

${OPENSHIFT_DATA_DIR}/.cabal/bin/shellcheck "${0}"

echo "$(date +%Y/%m/%d" "%H:%M:%S) FINISH"
