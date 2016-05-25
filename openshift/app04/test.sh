#!/bin/bash

echo "1135"

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

# -----

# convert --help

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

openssh_version=6.9

cd /tmp

wget -nc -q http://mirrors.sonic.net/pub/OpenBSD/OpenSSH/portable/openssh-${openssh_version}p1.tar.gz
tar xf openssh-${openssh_version}p1.tar.gz
cd openssh-${openssh_version}p1
ls -lang
wget -q http://osdn.jp/frs/g_redir.php?m=liquidtelecom&f=%2Fhpnssh%2FHPN-SSH+14v7+6.9p1%2Fopenssh-6_9_P1-hpn-14.7.diff -O openssh-6_9_P1-hpn-14.7.diff
cat openssh-6_9_P1-hpn-14.7.diff
patch < openssh-6_9_P1-hpn-14.7.diff
./configure --help

quota -s
echo "FINISH"
exit
