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

# if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
if [ 1 -eq 0 ]; then
    pushd ${OPENSHIFT_DATA_DIR} > /dev/null
    file_name=${OPENSHIFT_APP_UUID}_maked_ruby_${ruby_version}_rbenv.tar.xz
    url=$(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    while :
    do
        if [ $(wget -nv --spider --timeout 60 -t 1 ${url} 2>&1 | grep -c '200 OK') -eq 1 ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) ruby maked wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            break
        else
            echo "$(date +%Y/%m/%d" "%H:%M:%S) ruby maked waiting" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            sleep 10s
        fi
    done
    wget $(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ruby maked tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar Jxf ${file_name}
    rm -f ${file_name}
    popd > /dev/null
else
    pushd ${OPENSHIFT_TMP_DIR} > /dev/null
    rm -f ccache.tar.xz
    cp -f ${OPENSHIFT_DATA_DIR}/download_files/ccache_ruby.tar.xz ./ccache.tar.xz
    ccache -C
    if [ -f ccache.tar.xz ]; then
        rm -rf ccache
        time tar Jxf ccache.tar.xz
        rm -f ccache.tar.xz
    fi
    ccache -z
    popd > /dev/null

    oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}' | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ruby install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

    time \
     CONFIGURE_OPTS="--disable-install-doc --mandir=${OPENSHIFT_TMP_DIR}/man --docdir=${OPENSHIFT_TMP_DIR}/doc" \
     RUBY_CONFIGURE_OPTS="--with-out-ext=tk,tk/*" \
     MAKE_OPTS="-j $(grep -c -e processor /proc/cpuinfo)" \
     rbenv install -v ${ruby_version} >${OPENSHIFT_LOG_DIR}/ruby.rbenv.log 2>&1
    mv ${OPENSHIFT_LOG_DIR}/ruby.rbenv.log ${OPENSHIFT_LOG_DIR}/install/

    oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}' | tee -a ${OPENSHIFT_LOG_DIR}/install.log
fi

rbenv global ${ruby_version}
rbenv rehash
ruby -v
tree ${OPENSHIFT_DATA_DIR}.gem

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
ccache -s | tee -a ${OPENSHIFT_LOG_DIR}/install.log
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/is_make_ccache_data) = "yes" ]; then
    time tar Jcf ccache.tar.xz ccache
    mv -f ccache.tar.xz ${OPENSHIFT_DATA_DIR}/ccache_ruby.tar.xz
fi
popd > /dev/null

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
unset CC
unset CXX

for gem in bundler rack passenger
do
    gemfile=$(ls ${OPENSHIFT_DATA_DIR}/download_files/${gem}-*.gem)
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ${gemfile} install"
    time rbenv exec gem install --local ${gemfile} --no-rdoc --no-ri --debug \
     -V -- --with-cflags=\"-O2 -pipe -march=native -fomit-frame-pointer -s\" \
     > ${OPENSHIFT_LOG_DIR}/${gem}.gem.rbenv.log 2>&1
    rbenv rehash
    pushd ${OPENSHIFT_LOG_DIR} > /dev/null
    zip -9m ${gem}.gem.rbenv.log.zip ${gem}.gem.rbenv.log
    mv ${gem}.gem.rbenv.log.zip ./install/
    popd > /dev/null
done

rbenv exec gem list | tee -a ${OPENSHIFT_LOG_DIR}/install.log

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
