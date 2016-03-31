#!/bin/bash

echo "1657"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang

# wget --help
# curl --help

rm -f *.rpm

echo "START $(date +%Y/%m/%d" "%H:%M:%S)"

# curl -LI http://olea.org/paquetes-rpm/fedora-19/ShellCheck-0.2.0-2.fc19.x86_64.rpm
# wget http://olea.org/paquetes-rpm/fedora-19/ShellCheck-0.2.0-2.fc19.x86_64.rpm

# rpm2cpio ShellCheck-0.2.0-2.fc19.x86_64.rpm | cpio -idmv

# tree ./

echo ${LD_LIBRARY_PATH}
# export LD_LIBRARY_PATH=/tmp/usr/lib64/ghc-7.4.2/regex-compat-0.95.1:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=/tmp/usr/lib64
echo ${LD_LIBRARY_PATH}

cp /tmp/usr/lib64/ghc-7.4.2/regex-compat-0.95.1/libHSregex-compat-0.95.1-ghc7.4.2.so /tmp/usr/lib64/
./usr/bin/shellcheck --version
ldd ./usr/bin/shellcheck

# wget http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-regex-compat-0.95.1-22.fc19.x86_64.rpm
# rpm2cpio ghc-regex-compat-0.95.1-22.fc19.x86_64.rpm | cpio -idmv

wget http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-regex-posix-0.95.2-22.fc19.x86_64.rpm
rpm2cpio ghc-regex-posix-0.95.2-22.fc19.x86_64.rpm | cpio -idmv

wget http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-regex-base-0.93.2-22.fc19.x86_64.rpm
rpm2cpio ghc-regex-base-0.93.2-22.fc19.x86_64.rpm | cpio -idmv

tree ./

echo "FINISH $(date +%Y/%m/%d" "%H:%M:%S)"

ls -lang

exit
