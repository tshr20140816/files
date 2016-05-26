#!/bin/bash

echo "1425"

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

openssh_version=6.9

cd /tmp

wget -nc -q http://mirrors.sonic.net/pub/OpenBSD/OpenSSH/portable/openssh-${openssh_version}p1.tar.gz
tar xf openssh-${openssh_version}p1.tar.gz
cd openssh-${openssh_version}p1
ls -lang
wget -O openssh-6_9_P1-hpn-14.7.diff http://superb-sea2.dl.sourceforge.net/project/hpnssh/HPN-SSH%2014v7%206.9p1/openssh-6_9_P1-hpn-14.7.diff
# cat openssh-6_9_P1-hpn-14.7.diff
patch < openssh-6_9_P1-hpn-14.7.diff
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/ssh \
 --mandir=${OPENSHIFT_TMP_DIR}/gomi \
 --infodir=${OPENSHIFT_TMP_DIR}/gomi \
 --docdir=${OPENSHIFT_TMP_DIR}/gomi \
 --disable-largefile \
 --disable-etc-default-login \
 --disable-utmp \
 --disable-utmpx \
 --disable-wtmp \
 --disable-wtmpx \
 --without-ssh1 \
 --with-lastlog=${OPENSHIFT_LOG_DIR}/ssh_lastlog.log
time make
make install

tree ${OPENSHIFT_DATA_DIR}/ssh
quota -s
echo "FINISH"
exit
