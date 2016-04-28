#!/bin/bash

echo "1442"

set -x

quota -s
oo-cgroup-read memory.failcnt
echo "$(oo-cgroup-read memory.usage_in_bytes)" | awk '{printf "%\047d\n", $0}'

# oo-cgroup-read all
# oo-cgroup-read report

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

/usr/bin/gear start --trace

cd /tmp
ls -lang
cd $OPENSHIFT_DATA_DIR
ls -lang

quota -s

# -----

cd /tmp
rm -rf 20160425
rm -rf gomi
rm -rf ${OPENSHIFT_DATA_DIR}/usr

# -----

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

pushd ${OPENSHIFT_TMP_DIR}} > /dev/null
wget -q https://www.samba.org/ftp/ccache/ccache-3.2.4.tar.xz
tar Jxf ccache-3.2.4.tar.xz
rm -f ccache-3.2.4.tar.xz
pushd ccache-3.2.4 > /dev/null
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr --mandir=/dev/null --infodir=/dev/null
time make -j4
make install
popd > /dev/null
rm -rf ccache-3.2.4
popd > /dev/null

tree -a ${OPENSHIFT_DATA_DIR}/usr

quota -s
echo "FINISH"
exit
