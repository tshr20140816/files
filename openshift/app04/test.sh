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

# ls -lang

rm -rf ./usr
rm -rf shellcheck-0.2.0
rm -f ShellCheck.spec
rm -f v0.2.0.tar.gz
rm -f *.rpm
rm -f *.diff
rm -f dummy.txt
rm -f ghc-4.08.2-src.tar.bz2*

ls -lang

quota -s

exit
