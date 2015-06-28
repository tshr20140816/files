#!/bin/bash

# 1508

export TZ=JST-9

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

set -x

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

exit

cflag_data=$(gcc -march=native -E -v - </dev/null 2>&1 | sed -n 's/.* -v - //p')
export CFLAGS="-O2 ${cflag_data} -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

if [ 1 -eq 0 ]; then
cd /tmp
wget http://ftp.riken.jp/net/apache//httpd/httpd-2.2.29.tar.bz2

tar jxf httpd-2.2.29.tar.bz2
cd httpd-2.2.29
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/apache \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --enable-mods-shared='all proxy'

time make -j4
make install
cd $OPENSHIFT_DATA_DIR
rm -rf apache/manual
fi

if [ 1 -eq 0 ]; then
cd /tmp
rm rbenv-installer
wget https://raw.github.com/Seppone/openshift-rbenv-installer/master/bin/rbenv-installer
bash rbenv-installer
rm rbenv-installer

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"

time \
 CONFIGURE_OPTS="--disable-install-doc --mandir=${OPENSHIFT_TMP_DIR}/man --docdir=${OPENSHIFT_TMP_DIR}/doc" \
 RUBY_CONFIGURE_OPTS="--with-out-ext=tk,tk/*" \
 MAKE_OPTS="-j $(grep -c -e processor /proc/cpuinfo)" \
 rbenv install -v 2.1.6

tree ${OPENSHIFT_DATA_DIR}/.rbenv
tree ${OPENSHIFT_DATA_DIR}/.gem

rbenv global 2.1.6
rbenv rehash

find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
 | xargs -0 perl -pi -e "s/0\.0\.0\.0/${OPENSHIFT_PHP_IP}/g"

for gem in bundler rack passenger
do
    time rbenv exec gem install ${gem} --no-rdoc --no-ri --debug \
     -V -- --with-cflags=\"${CFLAGS}\"
    rbenv rehash
done
fi

if [ 1 -eq 0 ]; then
cd /tmp

export HOME=${OPENSHIFT_DATA_DIR}

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_COMPILERCHECK=none
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
rm -rf ${OPENSHIFT_TMP_DIR}/tmp_ccache
mkdir ${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M
export CCACHE_NLEVELS=3
ccache -s
ccache --zero-stats

export LD=ld.gold
rm -rf /tmp/local
mkdir -p /tmp/local/bin
cp -f /tmp/ld.gold /tmp/local/bin/
export PATH="/tmp/local/bin:$PATH"

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)" 
export PATH=${OPENSHIFT_DATA_DIR}/apache/bin:$PATH

rbenv global 2.1.6
rbenv rehash

time ${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module \
 --auto \
 --languages ruby \
 --apxs2-path ${OPENSHIFT_DATA_DIR}/apache/bin/apxs

ccache -s

tar Jcf ccache_passenger-install-apache2-module.tar.xz ccache
fi

tree ${OPENSHIFT_DATA_DIR}/.gem

find ${OPENSHIFT_DATA_DIR}/.gem -name '*.md' -type f -print0 | xargs -0i -t -P 4 -n 3 rm -f {}

tree ${OPENSHIFT_DATA_DIR}/.gem
