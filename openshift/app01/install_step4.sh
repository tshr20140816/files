#!/bin/bash

source functions.sh
function010 restart
[ $? -eq 0 ] || exit

# ***** ruby *****

rm -rf ${OPENSHIFT_DATA_DIR}.gem
rm -rf ${OPENSHIFT_DATA_DIR}.rbenv

# ホームディレクトリはパーミッションがきつい
export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem

# *** rbenv ***

echo "$(date +%Y/%m/%d" "%H:%M:%S) rbenv install" >> ${OPENSHIFT_LOG_DIR}/install.log

# OPENSHIFT用インストーラ
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/rbenv-installer ./
bash rbenv-installer
rm rbenv-installer
popd > /dev/null

export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"

# *** ruby ***

oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}' | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) ruby install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

export CFLAGS="-O2 -march=native" 
export CXXFLAGS="-O2 -march=native" 
time CONFIGURE_OPTS="--disable-install-doc --mandir=/tmp/man --docdir=/tmp/doc" \
MAKE_OPTS="-j$(grep -c -e processor /proc/cpuinfo)" \
rbenv install -v ${ruby_version} >${OPENSHIFT_LOG_DIR}/ruby.rbenv.log 2>&1
mv ${OPENSHIFT_LOG_DIR}/ruby.rbenv.log ${OPENSHIFT_LOG_DIR}/install/

oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}' | tee -a ${OPENSHIFT_LOG_DIR}/install.log

rbenv global ${ruby_version}
rbenv rehash

# # *** bundler ***
# 
# echo "$(date +%Y/%m/%d" "%H:%M:%S) bundler install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# 
# # patch resolv.rb
# # OPENSHIFT では  0.0.0.0 は使えないため OPENSHIFT_DIY_IP に置換
# find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
#  | xargs -0i cp -f {} ${OPENSHIFT_TMP_DIR}
# find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
#  | xargs -0 perl -pi -e "s/0\.0\.0\.0/${OPENSHIFT_DIY_IP}/g"
# find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
#  | xargs -0i sed -i -e "s|@config = Config.new(config_info)|@config = Config.new(:nameserver => ['8.8.8.8'])|g" {}
# 
# echo "$(date +%Y/%m/%d" "%H:%M:%S) resolv.rb patch check" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# # find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f \
# # | grep -e ${OPENSHIFT_DIY_IP} >> ${OPENSHIFT_LOG_DIR}/install.log
# find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
#  | xargs -0i diff -u ${OPENSHIFT_TMP_DIR}/resolv.rb {} | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# 
# # time rbenv exec gem install bundler --no-rdoc --no-ri --debug -V >${OPENSHIFT_LOG_DIR}/bundler.gem.rbenv.log 2>&1
# bundler_gem=$(ls ${OPENSHIFT_DATA_DIR}/download_files/bundler-*.gem)
# time rbenv exec gem install --local ${bundler_gem} --no-rdoc --no-ri --debug -V \
#  > ${OPENSHIFT_LOG_DIR}/bundler.gem.rbenv.log 2>&1
# rbenv rehash
# mv ${OPENSHIFT_LOG_DIR}/bundler.gem.rbenv.log ${OPENSHIFT_LOG_DIR}/install/
# 
# # *** passenger ***
# 
# echo "$(date +%Y/%m/%d" "%H:%M:%S) bundler passenger" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# 
# #time rbenv exec gem install passenger --no-ri --no-rdoc --debug -V >${OPENSHIFT_LOG_DIR}/passenger.gem.rbenv.log 2>&1
# rack_gem=$(ls ${OPENSHIFT_DATA_DIR}/download_files/rack-*.gem)
# time rbenv exec gem install --local ${rack_gem} --no-rdoc --no-ri --debug -V \
#  > ${OPENSHIFT_LOG_DIR}/rack.gem.rbenv.log 2>&1
# passenger_gem=$(ls ${OPENSHIFT_DATA_DIR}/download_files/passenger-*.gem)
# time rbenv exec gem install --local ${passenger_gem} --no-rdoc --no-ri --debug -V \
#  > ${OPENSHIFT_LOG_DIR}/passenger.gem.rbenv.log 2>&1
# rbenv rehash
# pushd ${OPENSHIFT_LOG_DIR} > /dev/null
# zip -9 passenger.gem.rbenv.log.zip passenger.gem.rbenv.log
# mv ${OPENSHIFT_LOG_DIR}/passenger.gem.rbenv.log.zip ${OPENSHIFT_LOG_DIR}/install/
# rm -f passenger.gem.rbenv.log

# *** bundler rack passenger ***

for ${gem} in bundler rack passenger
do
    gemfile=$(ls ${OPENSHIFT_DATA_DIR}/download_files/${gem}-*.gem)
    time rbenv exec gem install --local ${gemfile} --no-rdoc --no-ri --debug -V \
     > ${OPENSHIFT_LOG_DIR}/${gem}.gem.rbenv.log 2>&1
    rbenv rehash
    mv ${OPENSHIFT_LOG_DIR}/${gem}.gem.rbenv.log ${OPENSHIFT_LOG_DIR}/install/
done

popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
