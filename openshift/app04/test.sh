#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

cd /tmp
if [ ! -e ${OPENSHIFT_DATA_DIR}/ccache ]; then
    if [ ! -f ccache-3.2.1.tar.xz ]; then
        wget https://files3-20150207.rhcloud.com/files/ccache-3.2.1.tar.xz
    fi
    tar Jxf ccache-3.2.1.tar.xz
    cd ccache-3.2.1
    CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s" CXXFLAGS="-O2 -march=native -pipe" \
     ./configure --prefix=${OPENSHIFT_DATA_DIR}/ccache --mandir=/tmp/man --docdir=/tmp/doc
    make
    make install
fi

# export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
# export CC="ccache gcc"
# export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_MAXSIZE=300M
export CCACHE_BASEDIR=${OPENSHIFT_HOME_DIR}

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

# ccache -z

set -x

cd /tmp

mkdir bundle_test
cd bundle_test

rm -rf ${OPENSHIFT_DATA_DIR}/.gem
mkdir ${OPENSHIFT_DATA_DIR}/.gem
export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
gem --version
gem environment

cat << '__HEREDOC__' > Gemfile
class << Bundler.ui
  def tell_me (msg, color = nil, newline = nil)
    msg = word_wrap(msg) if newline.is_a?(Hash) && newline[:wrap]
    msg = "[#{Time.now}] " + msg if msg.length > 3
    if newline.nil?
      @shell.say(msg, color)
    else
      @shell.say(msg, color, newline)
    end
  end
end

source 'https://rubygems.org'

# gem install commander -v 4.2.1 --verbose --no-rdoc --no-ri -- --with-cflags=\"-O2 -pipe -march=native -fomit-frame-pointer -s\"
# gem install rhc --verbose --no-rdoc --no-ri -- --with-cflags=\"-O2 -pipe -march=native -fomit-frame-pointer -s\"

gem 'commander', '= 4.2.1'
gem 'rhc'
__HEREDOC__

gem install bundler --verbose --no-rdoc --no-ri -- --with-cflags=\"-O2 -pipe -march=native -fomit-frame-pointer -s\"
bundle install --jobs=4 --retry=3 --verbose
