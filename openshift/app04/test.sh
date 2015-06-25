#!/bin/bash

# 1507

export TZ=JST-9

tail -n 10000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
# cat ${OPENSHIFT_LOG_DIR}/distcc.log
cat ${OPENSHIFT_LOG_DIR}/distcc_ssh.log

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

# tree ${OPENSHIFT_DATA_DIR}.gem

rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log.*
rm -f ${OPENSHIFT_LOG_DIR}/ccache.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
rm -f ${OPENSHIFT_TMP_DIR}/distcc_server_stderr_*
ls -d /tmp/cc* | grep -v ccache$ | xargs rm -f

set -x

gcc -O2 -Q --help=optimize | grep -e enable
gcc -O2 -march=native -Q --help=optimize

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

cd /tmp

# tar Jcf ccache_passenger-install-apache2-module.tar.xz ccache

rm -f monitor_resourse.sh
wget https://github.com/tshr20140816/files/raw/master/openshift/app01/monitor_resourse.sh
chmod +x monitor_resourse.sh
./monitor_resourse.sh &
pid_1=$!

touch ${OPENSHIFT_LOG_DIR}/ccache.log
touch ${OPENSHIFT_LOG_DIR}/distcc.log
touch ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
tail -f ${OPENSHIFT_LOG_DIR}/ccache.log &
pid_2=$!
tail -f ${OPENSHIFT_LOG_DIR}/distcc.log &
pid_3=$!
tail -f ${OPENSHIFT_LOG_DIR}/distcc_ssh.log &
pid_4=$!

pushd ${OPENSHIFT_DATA_DIR}/.gem/gems/passenger-*
sed -i -e 's|make -j2|make -j6|g' build/common_library.rb
sed -i -e 's|cflags = "#{EXTRA_CFLAGS} -w"|cflags = "-O2 -w"|g' build/common_library.rb
grep -e make build/common_library.rb
grep -e cflags build/common_library.rb
popd

cflag_data=$(gcc -march=native -E -v - </dev/null 2>&1 | sed -n 's/.* -v - //p')
# export CFLAGS="-O2 ${cflag_data} -pipe -fomit-frame-pointer -s"
# export CFLAGS="-O2 -march=native"
export CFLAGS="-Wno-deprecated -Os -march=core2 -mcx16 -msahf -maes -mpclmul -mpopcnt -mavx -mtune=generic -s"
export CFLAGS="${CFLAGS} -fthread-jumps -fdefer-pop"

export CFLAGS="-Wno-deprecated "
export CFLAGS="${CFLAGS} -falign-functions"
export CFLAGS="${CFLAGS} -falign-jumps"
export CFLAGS="${CFLAGS} -falign-labels"
export CFLAGS="${CFLAGS} -fargument-alias"
export CFLAGS="${CFLAGS} -fasynchronous-unwind-tables"
export CFLAGS="${CFLAGS} -fbranch-count-reg"
export CFLAGS="${CFLAGS} -fcaller-saves"
export CFLAGS="${CFLAGS} -fcommon"
export CFLAGS="${CFLAGS} -fcprop-registers"
export CFLAGS="${CFLAGS} -fcrossjumping"
export CFLAGS="${CFLAGS} -fcse-follow-jumps"
export CFLAGS="${CFLAGS} -fdce"
export CFLAGS="${CFLAGS} -fdefer-pop"
export CFLAGS="${CFLAGS} -fdelete-null-pointer-checks"
export CFLAGS="${CFLAGS} -fdse"
export CFLAGS="${CFLAGS} -fearly-inlining"
export CFLAGS="${CFLAGS} -fexpensive-optimizations"
export CFLAGS="${CFLAGS} -fforward-propagate"
export CFLAGS="${CFLAGS} -fgcse"
export CFLAGS="${CFLAGS} -fgcse-lm"
export CFLAGS="${CFLAGS} -fguess-branch-probability"
export CFLAGS="${CFLAGS} -fif-conversion"
export CFLAGS="${CFLAGS} -fif-conversion2"
export CFLAGS="${CFLAGS} -finline-functions-called-once"
export CFLAGS="${CFLAGS} -finline-small-functions"
export CFLAGS="${CFLAGS} -fipa-cp"
export CFLAGS="${CFLAGS} -fipa-pure-const"
export CFLAGS="${CFLAGS} -fipa-reference"
export CFLAGS="${CFLAGS} -fivopts"
export CFLAGS="${CFLAGS} -fjump-tables"
export CFLAGS="${CFLAGS} -fmath-errno"
export CFLAGS="${CFLAGS} -fmerge-constants"
export CFLAGS="${CFLAGS} -fmove-loop-invariants"
export CFLAGS="${CFLAGS} -fomit-frame-pointer"
export CFLAGS="${CFLAGS} -foptimize-register-move"
export CFLAGS="${CFLAGS} -foptimize-sibling-calls"
export CFLAGS="${CFLAGS} -fpeephole"
export CFLAGS="${CFLAGS} -fpeephole2"
export CFLAGS="${CFLAGS} -fregmove"
export CFLAGS="${CFLAGS} -frename-registers"
export CFLAGS="${CFLAGS} -freorder-blocks"
export CFLAGS="${CFLAGS} -freorder-functions"
export CFLAGS="${CFLAGS} -frerun-cse-after-loop"
export CFLAGS="${CFLAGS} -fsched-interblock"
export CFLAGS="${CFLAGS} -fsched-spec"
export CFLAGS="${CFLAGS} -fsched-stalled-insns-dep"
export CFLAGS="${CFLAGS} -fschedule-insns2"
export CFLAGS="${CFLAGS} -fsigned-zeros"
export CFLAGS="${CFLAGS} -fsplit-ivs-in-unroller"
export CFLAGS="${CFLAGS} -fsplit-wide-types"
export CFLAGS="${CFLAGS} -fstrict-aliasing"
export CFLAGS="${CFLAGS} -fthread-jumps"
export CFLAGS="${CFLAGS} -ftoplevel-reorder"
export CFLAGS="${CFLAGS} -ftrapping-math"
export CFLAGS="${CFLAGS} -ftree-builtin-call-dce"
export CFLAGS="${CFLAGS} -ftree-ccp"
export CFLAGS="${CFLAGS} -ftree-ch"
export CFLAGS="${CFLAGS} -ftree-coalesce-vars"
export CFLAGS="${CFLAGS} -ftree-copy-prop"
export CFLAGS="${CFLAGS} -ftree-copyrename"
export CFLAGS="${CFLAGS} -ftree-cselim"
export CFLAGS="${CFLAGS} -ftree-dce"
export CFLAGS="${CFLAGS} -ftree-dominator-opts"
export CFLAGS="${CFLAGS} -ftree-dse"
export CFLAGS="${CFLAGS} -ftree-fre"
export CFLAGS="${CFLAGS} -ftree-loop-im"
export CFLAGS="${CFLAGS} -ftree-loop-ivcanon"
export CFLAGS="${CFLAGS} -ftree-loop-optimize"
export CFLAGS="${CFLAGS} -ftree-pre"
export CFLAGS="${CFLAGS} -ftree-reassoc"
export CFLAGS="${CFLAGS} -ftree-scev-cprop"
export CFLAGS="${CFLAGS} -ftree-sink"
export CFLAGS="${CFLAGS} -ftree-sra"
export CFLAGS="${CFLAGS} -ftree-switch-conversion"
export CFLAGS="${CFLAGS} -ftree-ter"
export CFLAGS="${CFLAGS} -ftree-vect-loop-version"
export CFLAGS="${CFLAGS} -ftree-vrp"
export CFLAGS="${CFLAGS} -funit-at-a-time"
export CFLAGS="${CFLAGS} -fvar-tracking"
export CFLAGS="${CFLAGS} -fvar-tracking-assignments"
export CFLAGS="${CFLAGS} -fvect-cost-model"
export CFLAGS="${CFLAGS} -fweb"

export CXXFLAGS="${CFLAGS}"

export EXTRA_CFLAGS="${CFLAGS}"
export EXTRA_CXXFLAGS="${CXXFLAGS}"

export HOME=${OPENSHIFT_DATA_DIR}

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"

export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
# rm -rf ${OPENSHIFT_TMP_DIR}/ccache
# mkdir ${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
rm -rf ${OPENSHIFT_TMP_DIR}/tmp_ccache
mkdir ${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_MAXSIZE=150M
export CCACHE_NLEVELS=3
export CCACHE_PREFIX=distcc

ccache -s
ccache --zero-stats

export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"

distcc_hosts_string="55630b63e0b8cd7ed000007f@v2-20150216.rhcloud.com/4:/var/lib/openshift/55630b63e0b8cd7ed000007f/app-root/data/distcc/bin/distccd_start"
distcc_hosts_string="${distcc_hosts_string} 55630afc5973caf283000214@v1-20150216.rhcloud.com/4:/var/lib/openshift/55630afc5973caf283000214/app-root/data/distcc/bin/distccd_start"
distcc_hosts_string="${distcc_hosts_string} 55630c675973caf283000251@v3-20150216.rhcloud.com/4:/var/lib/openshift/55630c675973caf283000251/app-root/data/distcc/bin/distccd_start"
export DISTCC_HOSTS="${distcc_hosts_string}"

export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc.log
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
export DISTCC_SSH="${OPENSHIFT_DATA_DIR}/bin/distcc-ssh"
export DISTCC_IO_TIMEOUT=1200

cat ${OPENSHIFT_DATA_DIR}/bin/distcc-ssh
cat ${OPENSHIFT_DATA_DIR}/.ssh/config

export LD=ld.gold
rm -rf /tmp/local
mkdir -p /tmp/local/bin
cp -f /tmp/ld.gold /tmp/local/bin/
export PATH="/tmp/local/bin:$PATH"

# *** env ***

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)" 
export PATH=${OPENSHIFT_DATA_DIR}/apache/bin:$PATH

export MAKEOPTS="-j 1"
# 32MB
# export RUBY_GC_MALLOC_LIMIT=33554432
# export RUBY_GC_MALLOC_LIMIT=16000000

export TRACE=1

# *** install ***

echo "# TEST" >> ${OPENSHIFT_DATA_DIR}/test.sh

${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-config --help-all
time ${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module \
 --auto \
 --languages ruby \
 --apxs2-path ${OPENSHIFT_DATA_DIR}/apache/bin/apxs

ccache -s

kill ${pid_1}
kill ${pid_2}
kill ${pid_3}
kill ${pid_4}
