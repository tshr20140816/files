#!/bin/bash

# rhc app create xxx diy-0.1 cron-1.4 --server openshift.redhat.com
# wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app04/install_distcc.sh
# chmod +x install_distcc.sh

set -x

export TZ=JST-9

if [ $# -ne 2 ]; then
    set +x
    echo "arg1 : web_beacon_server https://xxx/"
    echo "arg2 : web beacon server user (digest auth)"
    exit
fi

web_beacon_server=${1}
web_beacon_server_user=${2}

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

# ***** ccache *****

ccache_version=3.2.2

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://samba.org/ftp/ccache/ccache-${ccache_version}.tar.xz
tar Jxf ccache-${ccache_version}.tar.xz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/ccache-${ccache_version} > /dev/null
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/ccache \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

mkdir ${OPENSHIFT_TMP_DIR}/ccache
mkdir ${OPENSHIFT_TMP_DIR}/tmp_ccache

# ***** distcc *****

distcc_version=3.1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2
tar jxf distcc-${distcc_version}.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
# ./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/distcc \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/distcc/bin/distccd_start
#!/bin/bash

export DISTCC_TCP_CORK=0
export HOME=${OPENSHIFT_DATA_DIR}
export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
# export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M

# -pipe を入れたいけどメモリがきついときがある
export CFLAGS="-O2 -march=native -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"
# export CC="ccache gcc"
# export CXX="ccache g++"

exec ${OPENSHIFT_DATA_DIR}/distcc/bin/distccd $@
__HEREDOC__
chmod 755 ${OPENSHIFT_DATA_DIR}/distcc/bin/distccd_start

# ***** register url *****

curl --digest -u ${web_beacon_server_user}:$(date +%Y%m%d%H) -F "url=https://${OPENSHIFT_APP_DNS}/" \
 ${web_beacon_server}createwebcroninformation
