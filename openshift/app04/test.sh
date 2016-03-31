#!/bin/bash

echo "1718"

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

rm -rf ./usr
rm -f *.rpm

echo "START $(date +%Y/%m/%d" "%H:%M:%S)"

# curl -LI http://olea.org/paquetes-rpm/fedora-19/ShellCheck-0.2.0-2.fc19.x86_64.rpm
# wget http://olea.org/paquetes-rpm/fedora-19/ShellCheck-0.2.0-2.fc19.x86_64.rpm

# rpm2cpio ShellCheck-0.2.0-2.fc19.x86_64.rpm | cpio -idmv

# tree ./

wget http://olea.org/paquetes-rpm/fedora-19/ShellCheck-0.2.0-2.fc19.x86_64.rpm
rpm2cpio ShellCheck-0.2.0-2.fc19.x86_64.rpm | cpio -idmv

wget http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-regex-compat-0.95.1-22.fc19.x86_64.rpm
rpm2cpio ghc-regex-compat-0.95.1-22.fc19.x86_64.rpm | cpio -idmv

wget http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-regex-posix-0.95.2-22.fc19.x86_64.rpm
rpm2cpio ghc-regex-posix-0.95.2-22.fc19.x86_64.rpm | cpio -idmv

wget http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-regex-base-0.93.2-22.fc19.x86_64.rpm
rpm2cpio ghc-regex-base-0.93.2-22.fc19.x86_64.rpm | cpio -idmv

wget http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-json-0.7-2.fc19.x86_64.rpm
rpm2cpio ghc-json-0.7-2.fc19.x86_64.rpm | cpio -idmv

find ./ -name "*.so" -mindepth 2 -type f -print0 | xargs -0i -P 1 -n 1 mv -f {} /tmp/usr/lib64/

tree ./

export LD_LIBRARY_PATH=/tmp/usr/lib64
echo ${LD_LIBRARY_PATH}

./usr/bin/shellcheck --version
ldd ./usr/bin/shellcheck

echo "FINISH $(date +%Y/%m/%d" "%H:%M:%S)"

ls -lang

exit
