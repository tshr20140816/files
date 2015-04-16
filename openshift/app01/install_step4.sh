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

echo "$(date +%Y/%m/%d" "%H:%M:%S) rbenv install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

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
rbenv -v | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# *** ruby ***

oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}' | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) ruby install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# export CFLAGS="-O2 -march=native -pipe" 
# export CXXFLAGS="-O2 -march=native -pipe" 
# export CC="ccache gcc"
# export RUBY_CONFIGURE_OPTS="--with-out-ext=tk,tk/*"
time CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer" CXXFLAGS="-O2 -march=native -pipe" \
 CONFIGURE_OPTS="--disable-install-doc --mandir=/tmp/man --docdir=/tmp/doc" \
 RUBY_CONFIGURE_OPTS="--with-out-ext=tk,tk/*" \
 CC="ccache gcc" CXX="ccache g++" \
 MAKE_OPTS="-j $(grep -c -e processor /proc/cpuinfo)" \
 rbenv install -v ${ruby_version} >${OPENSHIFT_LOG_DIR}/ruby.rbenv.log 2>&1
mv ${OPENSHIFT_LOG_DIR}/ruby.rbenv.log ${OPENSHIFT_LOG_DIR}/install/

oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}' | tee -a ${OPENSHIFT_LOG_DIR}/install.log

rbenv global ${ruby_version}
rbenv rehash

# *** patch resolv.rb ***

# OPENSHIFT では  0.0.0.0 は使えないため OPENSHIFT_DIY_IP に置換
find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
 | xargs -0i cp -f {} ${OPENSHIFT_TMP_DIR}
find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
 | xargs -0 perl -pi -e "s/0\.0\.0\.0/${OPENSHIFT_DIY_IP}/g"
# # dns を強制的に google にする
# find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
#  | xargs -0i sed -i -e "s|@config = Config.new(config_info)|@config = Config.new(:nameserver => ['8.8.8.8'])|g" {}

# * patch check resolv.rb *
echo "$(date +%Y/%m/%d" "%H:%M:%S) resolv.rb diff" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
 | xargs -0i diff -u ${OPENSHIFT_TMP_DIR}/resolv.rb {}
echo "$(date +%Y/%m/%d" "%H:%M:%S) resolv.rb syntax check" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
 | xargs -0i ruby -cw {}

# *** bundler rack passenger ***

rbenv exec gem --version | tee -a ${OPENSHIFT_LOG_DIR}/install.log
rbenv exec gem env | tee -a ${OPENSHIFT_LOG_DIR}/install.log

for gem in bundler rack passenger
do
    gemfile=$(ls ${OPENSHIFT_DATA_DIR}/download_files/${gem}-*.gem)
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ${gemfile} install"
    time rbenv exec gem install --local ${gemfile} --no-rdoc --no-ri --debug -V \
     > ${OPENSHIFT_LOG_DIR}/${gem}.gem.rbenv.log 2>&1
    rbenv rehash
    pushd ${OPENSHIFT_LOG_DIR} > /dev/null
    zip -9m ${gem}.gem.rbenv.log.zip ${gem}.gem.rbenv.log
    mv ${gem}.gem.rbenv.log.zip ./install/
    popd > /dev/null
done

rbenv exec gem list | tee -a ${OPENSHIFT_LOG_DIR}/install.log

popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
