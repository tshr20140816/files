#!/bin/bash

echo "1621"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang

rm -rf ./usr
rm -rf shellcheck-0.2.0
rm -f ShellCheck.spec
rm -f v0.2.0.tar.gz
rm -f *.rpm
rm -f *.diff
rm -f dummy.txt
rm -f ghc-4.08.2-src.tar.bz2*

# wget http://olea.org/paquetes-rpm/fedora-19/ShellCheck-0.2.0-2.fc19.src.rpm

# rpm2cpio ShellCheck-0.2.0-2.fc19.src.rpm | cpio -idmv
# tar zxf v0.2.0.tar.gz

# tree ./

# cat ./shellcheck-0.2.0/Makefile

find / -name config.guess -print 2>/dev/null
find / -name config.sub -print 2>/dev/null

# wget -q https://www.haskell.org/ghc/dist/6.10.4/ghc-6.10.4-src.tar.bz2
wget -q https://downloads.haskell.org/~ghc/4.08.2/ghc-4.08.2-src.tar.bz2

tar jxf ghc-4.08.2-src.tar.bz2
cd ghc-4.08.2
cp /usr/lib/rpm/config.guess .
cp /usr/lib/rpm/config.sub .

./configure --help
./configure --prefix=/tmp/ghc4
time make

quota -s

exit
