#!/bin/bash

# export HOME=${OPENSHIFT_DATA_DIR}
# export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
# export PATH="${OPENSHIFT_DATA_DIR}/openssh/bin:${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
# ssh xxxxx@xxxxx-xxxxx.rhcloud.com
# export DISTCC_HOSTS='xxxxx@xxxxx-xxxxx.rhcloud.com:/var/lib/openshift/xxxxx/app-root/data/distcc/bin/distccd'
# export CC=distcc
# export DISTCC_DIR=/tmp/

# vi app-root/data/.ssh/config
# Host *
# ControlMaster auto
# ControlPath /tmp/.ssh_tmp/master-%r@%h:%p

# ssh -fMN xxxxx@xxxxx-xxxxx.rhcloud.com

set -x

export TZ=JST-9

# ***** distcc *****

distcc_version=3.1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2
tar jxf distcc-${distcc_version}.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
# ./configure --help
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

exec ${OPENSHIFT_DATA_DIR}/distcc/bin/distccd $@
__HEREDOC__
