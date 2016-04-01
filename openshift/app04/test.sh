#!/bin/bash

echo "1006"

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

/lib64/libc.so.6

rm -rf ./usr
rm -rf ./etc
rm -rf ./lib64
rm -rf ./sbin
rm -rf ./var

rm -f *.rpm

echo "START $(date +%Y/%m/%d" "%H:%M:%S)"

# curl -LI http://olea.org/paquetes-rpm/fedora-19/ShellCheck-0.2.0-2.fc19.x86_64.rpm
# wget http://olea.org/paquetes-rpm/fedora-19/ShellCheck-0.2.0-2.fc19.x86_64.rpm

# rpm2cpio ShellCheck-0.2.0-2.fc19.x86_64.rpm | cpio -idmv

# tree ./

wget -q http://olea.org/paquetes-rpm/fedora-19/ShellCheck-0.2.0-2.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-regex-compat-0.95.1-22.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-regex-posix-0.95.2-22.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-regex-base-0.93.2-22.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-json-0.7-2.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-syb-0.3.7-22.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-pretty-1.1.1.0-11.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-parsec-3.1.3-22.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-text-0.11.2.3-22.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-mtl-2.1.2-22.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-transformers-0.3.0.0-22.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-directory-1.1.0.2-11.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-unix-2.5.1.1-11.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-bytestring-0.9.2.1-11.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-old-time-1.1.0.0-11.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-old-locale-1.0.0.4-11.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-filepath-1.3.0.0-11.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-containers-0.4.2.1-11.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-deepseq-1.3.0.0-11.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-array-0.4.0.0-11.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/ghc-base-4.5.1.0-11.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/gmp-5.1.1-2.fc19.x86_64.rpm
wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/l/libffi-3.0.13-4.fc19.x86_64.rpm

for rpmball in $(find ./ -name "*.rpm" -type f -print)
do
    rpm2cpio ${rpmball} | cpio -idmv
done

wget -q http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/19/Everything/x86_64/os/Packages/g/glibc-2.17-4.fc19.x86_64.rpm
rpm2cpio glibc-2.17-4.fc19.x86_64.rpm | cpio -idmv

tree ./

/tmp/lib64/libc-2.17.so
ldd /tmp/lib64/libc-2.17.so

ln -s /tmp/lib64/libc-2.17.so /tmp/usr/lib64/libc.so.6

# export LD_LIBRARY_PATH=/tmp/lib64:/tmp/usr/lib64
export LD_LIBRARY_PATH=/tmp/usr/lib64
echo ${LD_LIBRARY_PATH}

/tmp/lib64/libc.so.6
./usr/bin/shellcheck --version
ldd ./usr/bin/shellcheck

echo "FINISH $(date +%Y/%m/%d" "%H:%M:%S)"

quota -s

ls -lang

exit
