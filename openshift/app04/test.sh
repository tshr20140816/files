#!/bin/bash

echo "0948"

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

cd /tmp
mkdir 20160425
cd 20160425
wget -nc -q https://yum.gleez.com/6/x86_64/hhvm-3.5.0-4.el6.x86_64.rpm
rpm2cpio hhvm-3.5.0-4.el6.x86_64.rpm | cpio -idmv
tree -a ./

cd etc/hhvm 
[ ! -f server.ini.org ] && mv -f server.ini server.ini.org
cat << __HEREDOC__ > server.ini
pid = ${OPENSHIFT_DATA_DIR}/var/run/hhvm/pid
hhvm.server.port = 39001
hhvm.server.type = fastcgi
hhvm.server.default_document = index.php
hhvm.log.use_log_file = true
hhvm.log.file = ${OPENSHIFT_LOG_DIR}/hhvm_error.log
hhvm.repo.central.path = ${OPENSHIFT_DATA_DIR}/var/run/hhvm/hhvm.hhbc
__HEREDOC__

cat server.ini

quota -s
echo "FINISH"
exit
