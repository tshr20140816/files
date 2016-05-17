#!/bin/bash

echo "1153"

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
rm -rf ccache-3.2.5 ccache gomi
rm -f ccache-3.2.5.tar.xz

# -----

cd /tmp

cat << '__HEREDOC__' > filter.pl
#/usr/bin/perl

print 'start\n';

my $alltext = $ARGV[0];

$alltext =~ s/hoge/moge/m;

print $alltext;

print 'finish\n';
__HEREDOC__

cat << '__HEREDOC__' > testdata.txt
test1
hoge
hoge
test2
__HEREDOC__

perl filter.pl < testdata.txt

quota -s
echo "FINISH"
exit
