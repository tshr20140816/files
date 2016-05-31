#!/bin/bash

echo "1128"

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
ls -lang $OPENSHIFT_REPO_DIR

quota -s

# -----

cd /tmp
rm -rf gmp-4.3.2 mpc-0.8.2 mpfr-2.4.2 openssh-6.9p1 bin info 20160523

cd $OPENSHIFT_DATA_DIR
rm -rf ssh

# -----

# convert --help

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd /tmp
mkdir 20160523
cd 20160523

gcc_version=4.4.7

[ -f gcc-core-${gcc_version}.tar.bz2 ] || wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-${gcc_version}/gcc-core-${gcc_version}.tar.bz2
rm -rf gcc-${gcc_version}
tar jxf gcc-core-${gcc_version}.tar.bz2
cd gcc-${gcc_version}
./configure

quota -s
echo "FINISH"
exit
