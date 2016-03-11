#!/bin/bash

# rhc app create xxx php-5.4 cron-1.4 --server openshift.redhat.com
# wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app05/install_distcc_client.sh
# chmod +x install_distcc_client.sh

set -x

export TZ=JST-9

if [ $# -ne 2 ]; then
    set +x
    echo "arg1 : web_beacon_server https://xxx/"
    echo "arg2 : web beacon server user (digest auth)"
    exit
fi

web_beacon_server=${1}
web_beacon_server_user=${2}

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

# ***** distcc *****

distcc_version=3.1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2
tar jxf distcc-${distcc_version}.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/distcc \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/distcc/bin/distccd_start
#!/bin/bash

export DISTCC_TCP_CORK=0
export HOME=${OPENSHIFT_DATA_DIR}
export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc/$(date +%Y%m%d).$$.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) $@" >> ${DISTCC_LOG}
exec ${OPENSHIFT_DATA_DIR}/distcc/bin/distccd $@
__HEREDOC__
chmod 755 ${OPENSHIFT_DATA_DIR}/distcc/bin/distccd_start

# ***** Closure Compiler *****

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
wget http://dl.google.com/closure-compiler/compiler-latest.zip
unzip compiler-latest.zip
popd > /dev/null

# ***** PHP (Closure Compiler) *****

pushd ${OPENSHIFT_REPO_DIR} > /dev/null
wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app05/closure_compiler.php
popd > /dev/null

# ***** cron *****

# *** hourly ***

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/hourly > /dev/null
rm -f ./*
touch jobs.deny


cat << '__HEREDOC__' > delete_log.sh
#!/bin/bash
export TZ=JST-9

find ${OPENSHIFT_LOG_DIR}/distcc/ -mtime +2 -print0 | xargs -0i -P 1 -n 1 rm -f {}
__HEREDOC__
chmod +x delete_log.sh
echo delete_log.sh >> jobs.allow

popd > /dev/null

# ***** register url *****

curl --digest -u ${web_beacon_server_user}:$(date +%Y%m%d%H) -F "url=https://${OPENSHIFT_APP_DNS}/" \
 ${web_beacon_server}createwebcroninformation
