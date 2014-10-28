#!/bin/bash

set -x

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 14 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** Tcl *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/tcl${tcl_version}-src.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` Tcl tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz tcl${tcl_version}-src.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/tcl${tcl_version}/unix > /dev/null
echo `date +%Y/%m/%d" "%H:%M:%S` Tcl configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/tcl 2>&1 | tee ${OPENSHIFT_LOG_DIR}/tcl.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` Tcl make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j4 2>&1 | tee ${OPENSHIFT_LOG_DIR}/tcl.make.log

echo `date +%Y/%m/%d" "%H:%M:%S` Tcl make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm tcl${tcl_version}-src.tar.gz
# TODO
# rm -rf tcl${tcl_version}
popd > /dev/null

# ***** Expect *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/expect${expect_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` Expect tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz expect${expect_version}.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/expect${expect_version} > /dev/null
echo `date +%Y/%m/%d" "%H:%M:%S` Expect configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/expect 2>&1 | tee ${OPENSHIFT_LOG_DIR}/expect.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` Expect make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j4 2>&1 | tee ${OPENSHIFT_LOG_DIR}/expect.make.log

echo `date +%Y/%m/%d" "%H:%M:%S` Expect make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm expect${expect_version}.tar.gz
rm -rf expect${expect_version}
popd > /dev/null

# ***** rhc *****

# *** env ***

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"

# *** install ***

echo `date +%Y/%m/%d" "%H:%M:%S` rhc install >> ${OPENSHIFT_LOG_DIR}/install.log

gem install rhc --no-rdoc --no-ri --verbose 2>&1 | tee ${OPENSHIFT_LOG_DIR}/rhc.gem.log

# *** setup ***

echo `date +%Y/%m/%d" "%H:%M:%S` rhc setup >> ${OPENSHIFT_LOG_DIR}/install.log

openshift_email_address=`cat ${OPENSHIFT_DATA_DIR}/openshift_email_address`
openshift_email_password=`cat ${OPENSHIFT_DATA_DIR}/openshift_email_password`

echo set timeout 60 > ${OPENSHIFT_TMP_DIR}/rhc_setup.txt
echo spawn ${OPENSHIFT_HOMEDIR}.gem/bin/rhc setup --server openshift.redhat.com --create-token -l ${openshift_email_address} -p ${openshift_email_password} >> ${OPENSHIFT_TMP_DIR}/rhc_setup.txt
cat << '__HEREDOC__' >> ${OPENSHIFT_TMP_DIR}/rhc_setup.txt
expect "(yes|no)"
send "yes\r"
expect "(yes|no)"
send "yes\r"
expect "Provide a name for this key"
send "\r"
interact
__HEREDOC__

env_home_backup=${HOME}
export HOME=${OPENSHIFT_DATA_DIR}
${OPENSHIFT_DATA_DIR}/tcl/bin/expect -f ${OPENSHIFT_TMP_DIR}/rhc_setup.txt 2>&1 | tee ${OPENSHIFT_LOG_DIR}/rhc.setup.log

${OPENSHIFT_HOMEDIR}.gem/bin/rhc apps | grep uuid >> ${OPENSHIFT_LOG_DIR}/install.log
${OPENSHIFT_HOMEDIR}.gem/bin/rhc apps | grep uuid
export HOME=${env_home_backup}

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 14 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
