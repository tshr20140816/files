#!/bin/bash

# rhc app create xxx diy-0.1 cron-1.4 --server openshift.redhat.com
# wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app05/install_distcc.sh
# chmod +x install_distcc.sh

set -x

export TZ=JST-9

if [ $# -ne 2 ]; then
    set +x
    echo "arg1 : web_beacon_server https://xxx/"
    echo "arg2 : web beacon server user (digest auth)"
    echo "arg3 : url for gcc493.tar.xz"
    exit
fi

web_beacon_server=${1}
web_beacon_server_user=${2}
# url_gcc493_tar_xz=${3}

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

if [ 0 -eq 1 ]; then
# ***** fio *****

# *** install ***

fio_version=2.2.9

rm -rf ${OPENSHIFT_TMP_DIR}/fio-${fio_version}
rm -rf ${OPENSHIFT_DATA_DIR}/fio
rm -f ${OPENSHIFT_TMP_DIR}/fio-${fio_version}.tar.bz2
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget http://brick.kernel.dk/snaps/fio-${fio_version}.tar.bz2
tar jxf fio-${fio_version}.tar.bz2
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/fio-${fio_version} > /dev/null
./configure --help
./configure
time make -j$(grep -c -e processor /proc/cpuinfo)
sed -i -E "s|^prefix .+$|prefix = ${OPENSHIFT_DATA_DIR}fio|g" Makefile
make install
popd > /dev/null

rm ${OPENSHIFT_TMP_DIR}/fio-${fio_version}.tar.bz2

# *** run ***

rm -rf ${OPENSHIFT_DATA_DIR}/work
pushd ${OPENSHIFT_DATA_DIR}fio > /dev/null
for rwtype in read write randread randwrite
do
    mkdir ${OPENSHIFT_DATA_DIR}/work

    ./bin/fio -rw=${rwtype} -bs=4k -size=10m -numjobs=10 -runtime=60 \
    -direct=1 -invalidate=1 \
    -iodepth=32 -iodepth_batch=32 -group_reporting -name=${rwtype} -directory=${OPENSHIFT_DATA_DIR}/work \
     | tee ${OPENSHIFT_LOG_DIR}/fio_${rwtype}.log

    aggrb=$(grep -e aggrb ${OPENSHIFT_LOG_DIR}/fio_${rwtype}.log | awk '{print $3}' | tr -d KB/s,)
    query_string="server=${OPENSHIFT_APP_DNS}&fio=${rwtype}&${aggrb}&uuid=${USER}"
    wget --spider $(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}

    mv ${OPENSHIFT_LOG_DIR}/fio_${rwtype}.log ${OPENSHIFT_LOG_DIR}/install/
    rm -rf ${OPENSHIFT_DATA_DIR}/work
done
popd > /dev/null
fi

# ***** gcc 4.9.3 *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
# wget ${url_gcc493_tar_xz}
# tar Jxf gcc493.tar.xz
popd > /dev/null

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
export DISTCC_LOG=/dev/null

# export PATH="${OPENSHIFT_TMP_DIR}/gcc/bin:$PATH"
# export LD_LIBRARY_PATH="${OPENSHIFT_TMP_DIR}/gcc/lib64:$LD_LIBRARY_PATH"
# export CC=gcc-493
# export CXX=gcc-493

exec ${OPENSHIFT_DATA_DIR}/distcc/bin/distccd $@
__HEREDOC__
chmod 755 ${OPENSHIFT_DATA_DIR}/distcc/bin/distccd_start

# ***** register url *****

curl --digest -u ${web_beacon_server_user}:$(date +%Y%m%d%H) -F "url=https://${OPENSHIFT_APP_DNS}/" \
 ${web_beacon_server}createwebcroninformation
