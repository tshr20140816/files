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

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cat << '__HEREDOC__' > build_request.xml
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <passsword value="build" />
  <uuid value="__UUID__" />
  <data_dir value="__DATA_DIR__" />
  <tmp_dir value="__TMP_DIR__" />
  <items>
    <item app="apache" version="2.2.29" />
    <item app="ruby" version="2.1.6" />
    <item app="php" version="5.6.8" />
    <item app="libmemcached" version="1.0.18" />
    <item app="delegate" version="9.9.13" />
    <item app="tcl" version="8.6.3" />
  </items>
</root>
__HEREDOC__
sed -i -e "s|__UUID__|${OPENSHIFT_APP_UUID}|g" build_request.xml
sed -i -e "s|__DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" build_request.xml
sed -i -e "s|__TMP_DIR__|${OPENSHIFT_TMP_DIR}|g" build_request.xml

if [ ${build_server_password} != 'none' ]; then
    wget --post-file=build_request.xml https://files1-20150207.rhcloud.com/files/build_action.php -O -
fi
popd > /dev/null
