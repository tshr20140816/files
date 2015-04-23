#!/bin/bash

echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

# dummy

cd /tmp
if [ ! -e ${OPENSHIFT_DATA_DIR}/ccache ]; then
    if [ ! -f ccache-3.2.1.tar.xz ]; then
        wget https://files3-20150207.rhcloud.com/files/ccache-3.2.1.tar.xz
    fi
    tar Jxf ccache-3.2.1.tar.xz
    cd ccache-3.2.1
    CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s" CXXFLAGS="-O2 -march=native -pipe" \
     ./configure --prefix=${OPENSHIFT_DATA_DIR}/ccache --mandir=/tmp/man --docdir=/tmp/doc
    make
    make install
fi

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_MAXSIZE=300M
export CCACHE_BASEDIR=${OPENSHIFT_HOME_DIR}

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

cd /tmp
wget http://vault.centos.org/6.3/os/Source/SPackages/initscripts-9.03.31-2.el6.centos.src.rpm
rpm2cpio initscripts-9.03.31-2.el6.centos.src.rpm | cpio -id
tar xjf initscripts-9.03.31.tar.bz2
cp initscripts-9.03.31/rc.d/init.d/functions ${OPENSHIFT_LOG_DIR}

rm -f initscripts-9.03.31-2.el6.centos.src.rpm
rm -rf initscripts-9.03.31

ls -lang
