#!/bin/bash

# 2224

export TZ=JST-9

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

set -x

cd /tmp

ls -lang

wget http://kegel.com/crosstool/crosstool-0.43.tar.gz
tar zxf crosstool-0.43.tar.gz
ls -lang crosstool-0.43/

exit

pstring=$(head -n 1 test1.txt)
build_server_password=${pstring:25:5}

# ***** build request *****

apache_version=2.2.29
ruby_version=2.1.6
libmemcached_version=1.0.18
delegate_version=9.9.13
tcl_version=8.6.3
cadaver_version=0.23.3
php_version=5.6.11

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cat << '__HEREDOC__' > build_request.xml
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <passsword value="__PASSWORD__" />
  <uuid value="__UUID__" />
  <data_dir value="__DATA_DIR__" />
  <tmp_dir value="__TMP_DIR__" />
  <items>
    <item app="apache" version="__APACHE_VERSION__" />
    <item app="ruby" version="__RUBY_VERSION__" />
    <item app="libmemcached" version="__LIBMEMCACHED_VERSION__" />
    <item app="delegate" version="__DELEGATE_VERSION__" />
    <item app="tcl" version="__TCL_VERSION__" />
    <item app="cadaver" version="__CADAVER_VERSION__" />
    <item app="php" version="__PHP_VERSION__" />
  </items>
</root>
__HEREDOC__
sed -i -e "s|__PASSWORD__|${build_server_password}|g" build_request.xml
sed -i -e "s|__UUID__|${OPENSHIFT_APP_UUID}|g" build_request.xml
sed -i -e "s|__DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" build_request.xml
sed -i -e "s|__TMP_DIR__|${OPENSHIFT_TMP_DIR}|g" build_request.xml
sed -i -e "s|__APACHE_VERSION__|${apache_version}|g" build_request.xml
sed -i -e "s|__RUBY_VERSION__|${ruby_version}|g" build_request.xml
sed -i -e "s|__LIBMEMCACHED_VERSION__|${libmemcached_version}|g" build_request.xml
sed -i -e "s|__DELEGATE_VERSION__|${delegate_version}|g" build_request.xml
sed -i -e "s|__TCL_VERSION__|${tcl_version}|g" build_request.xml
sed -i -e "s|__CADAVER_VERSION__|${cadaver_version}|g" build_request.xml
sed -i -e "s|__PHP_VERSION__|${php_version}|g" build_request.xml

mirror_server="https://files4-20150524.rhcloud.com/files/"

if [ ${build_server_password} != 'none' ]; then
    wget --post-file=build_request.xml ${mirror_server}build_action.php -O -
fi
popd > /dev/null
