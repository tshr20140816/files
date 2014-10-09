#!/bin/bash

set -x

while read LINE
do
  product=`echo $LINE | awk '{print $1}'`
  version=`echo $LINE | awk '{print $2}'`
  eval "$product"=$version
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 3 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

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
popd > /dev/nul

export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"

# *** ruby ***

echo `date +%Y/%m/%d" "%H:%M:%S` ruby install >> ${OPENSHIFT_LOG_DIR}/install.log

export CFLAGS="-O3 -march=native -pipe" 
export CXXFLAGS="-O3 -march=native -pipe" 
time CONFIGURE_OPTS="--disable-install-rdoc" rbenv install -v ${ruby_version}
rbenv global ${ruby_version}
rbenv rehash

# *** bundler ***

echo `date +%Y/%m/%d" "%H:%M:%S` bundler install >> ${OPENSHIFT_LOG_DIR}/install.log

# patch resolv.rb
# OPENSHIFT では  0.0.0.0 は使えないため
# perl -pi -e "s/0\.0\.0\.0/${OPENSHIFT_DIY_IP}/g" ${OPENSHIFT_DATA_DIR}/.rbenv/versions/${ruby_version}/lib/ruby/2.1.0/resolv.rb
find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f \
| xargs perl -pi -e "s/0\.0\.0\.0/${OPENSHIFT_DIY_IP}/g"

echo `date +%Y/%m/%d" "%H:%M:%S` resolv.rb patch check >> ${OPENSHIFT_LOG_DIR}/install.log
find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f \
| grep ${OPENSHIFT_DIY_IP} >> ${OPENSHIFT_LOG_DIR}/install.log

time rbenv exec gem install bundler --no-rdoc --no-ri --debug -V
rbenv rehash

# *** passenger ***

echo `date +%Y/%m/%d" "%H:%M:%S` bundler passenger >> ${OPENSHIFT_LOG_DIR}/install.log

time rbenv exec gem install passenger --no-ri --no-rdoc --debug -V
rbenv rehash

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 3 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
