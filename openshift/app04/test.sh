#!/bin/bash

echo "1247"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang

rm -rf shellcheck-0.2.0
rm -f ShellCheck.spec
rm -f v0.2.0.tar.gz
rm -f *.rpm
rm -f ghc-6.10.4-x86_64-unknown-linux-n.tar.bz2
rm -rf ghc-6.10.4

whereis ghc

# wget http://olea.org/paquetes-rpm/fedora-19/ShellCheck-0.2.0-2.fc19.src.rpm

# rpm2cpio ShellCheck-0.2.0-2.fc19.src.rpm | cpio -idmv
# tar zxf v0.2.0.tar.gz

# tree ./

# cat ./shellcheck-0.2.0/Makefile

wget -q https://www.haskell.org/ghc/dist/6.10.4/ghc-6.10.4-x86_64-unknown-linux-n.tar.bz2

tar jxf ghc-6.10.4-x86_64-unknown-linux-n.tar.bz2

rm -rf ./*.html
rm -rf ./*.pdf
rm -rf ./*.ps

find ./ -name '*.html' -type f -print0 | xargs -0i rm -f {}
find ./ -name '*.js' -type f -print0 | xargs -0i rm -f {}
find ./ -name '*.css' -type f -print0 | xargs -0i rm -f {}
find ./ -name '*.pdf' -type f -print0 | xargs -0i rm -f {}
find ./ -name '*.ps' -type f -print0 | xargs -0i rm -f {}

# tree ./

cd ghc-6.10.4

./configure --help
./configure

quota -s

exit
