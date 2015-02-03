#!/bin/bash

wget --spider `cat ${OPENSHIFT_DATA_DIR}/web_beacon_server`dummy?server=${OPENSHIFT_GEAR_DNS}\&part=`basename $0 .sh` >/dev/null 2>&1

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

set -x

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 4 Start | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# ***** ruby *****

# ホームディレクトリはパーミッションがきつい
export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem

# *** rbenv ***

echo `date +%Y/%m/%d" "%H:%M:%S` rbenv install >> ${OPENSHIFT_LOG_DIR}/install.log

# OPENSHIFT用インストーラ
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/rbenv-installer ./
bash rbenv-installer
rm rbenv-installer
popd > /dev/null

export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"

# *** ruby ***

echo `date +%Y/%m/%d" "%H:%M:%S` ruby install | tee -a ${OPENSHIFT_LOG_DIR}/install.log

export CFLAGS="-O3 -march=native -pipe" 
export CXXFLAGS="-O3 -march=native -pipe" 
time CONFIGURE_OPTS="--disable-install-doc" rbenv install -v ${ruby_version} >${OPENSHIFT_LOG_DIR}/ruby.rbenv.log 2>&1
rbenv global ${ruby_version}
rbenv rehash

# *** bundler ***

echo `date +%Y/%m/%d" "%H:%M:%S` bundler install | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# patch resolv.rb
# OPENSHIFT では  0.0.0.0 は使えないため
find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f \
| xargs perl -pi -e "s/0\.0\.0\.0/${OPENSHIFT_DIY_IP}/g"

echo `date +%Y/%m/%d" "%H:%M:%S` resolv.rb patch check | tee -a ${OPENSHIFT_LOG_DIR}/install.log
find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f \
| grep ${OPENSHIFT_DIY_IP} >> ${OPENSHIFT_LOG_DIR}/install.log

time rbenv exec gem install bundler --no-rdoc --no-ri --debug -V >${OPENSHIFT_LOG_DIR}/bundler.gem.rbenv.log 2>&1
rbenv rehash

# *** passenger ***

echo `date +%Y/%m/%d" "%H:%M:%S` bundler passenger | tee -a ${OPENSHIFT_LOG_DIR}/install.log

time rbenv exec gem install passenger --no-ri --no-rdoc --debug -V >${OPENSHIFT_LOG_DIR}/passenger.gem.rbenv.log 2>&1
rbenv rehash

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 4 Finish | tee -a ${OPENSHIFT_LOG_DIR}/install.log
