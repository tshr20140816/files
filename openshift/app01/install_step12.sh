#!/bin/bash

source functions.sh
function010 restart
[ $? -eq 0 ] || exit

export MAKEOPTS="-j6"
export HOME=${OPENSHIFT_DATA_DIR}

# ***** etc *****

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"

${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module --snippet > ${OPENSHIFT_TMP_DIR}/passenger.conf
cat ${OPENSHIFT_TMP_DIR}/passenger.conf

# *** passenger patch ***

# patch request_handler.rb
# OPENSHIFT では 127.0.0.1 は使えないため ${OPENSHIFT_DIY_IP} に置換
# https://help.openshift.com/hc/en-us/articles/202185874
# 15000 - 35530
find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name request_handler.rb -type f -print0 \
 | xargs -0i cp -f {} ${OPENSHIFT_TMP_DIR}
# find ${OPENSHIFT_DATA_DIR} -name request_handler.rb -type f \
#  | grep -e lib/phusion_passenger/request_handler.rb \
#  | xargs perl -pi -e "s/new\(\'127.0.0.1\', 0\)/new(\'${OPENSHIFT_DIY_IP}\', rand(15000..20000))/g"
find ${OPENSHIFT_DATA_DIR} -name request_handler.rb -type f \
 | grep -e lib/phusion_passenger/request_handler.rb \
 | xargs perl -pi -e "s/new\(\'127.0.0.1\', 0\)/new(\'${OPENSHIFT_DIY_IP}\', 15777)/g"

find ${OPENSHIFT_DATA_DIR} -name request_handler.rb -type f \
 | grep -e lib/phusion_passenger/request_handler.rb \
 | xargs perl -pi -e 's/127.0.0.1/$ENV{OPENSHIFT_DIY_IP}/g'

# *** patch check ***

echo "$(date +%Y/%m/%d" "%H:%M:%S) request_handler.rb diff" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name request_handler.rb -type f -print0 \
 | xargs -0i diff -u ${OPENSHIFT_TMP_DIR}/request_handler.rb {}
echo "$(date +%Y/%m/%d" "%H:%M:%S) request_handler.rb syntax check" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name request_handler.rb -type f -print0 \
 | xargs -0i ruby -cw {}

# ***** font *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) font install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
# cp ${OPENSHIFT_DATA_DIR}/download_files/IPAfont${ipafont_version}.zip ./
# unzip -d fonts -j IPAfont${ipafont_version}.zip
# rm IPAfont${ipafont_version}.zip
cp ${OPENSHIFT_DATA_DIR}/download_files/ipagp${ipafont_version}.zip ./
unzip -d fonts -j ipagp${ipafont_version}.zip
rm ipagp${ipafont_version}.zip
popd > /dev/null

# ***** redmine *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) redmine install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# *** redmine ***

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/redmine-${redmine_version}.tar.gz ./

echo "$(date +%Y/%m/%d" "%H:%M:%S) redmine tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
time tar zxf redmine-${redmine_version}.tar.gz
rm redmine-${redmine_version}.tar.gz
popd > /dev/null

# *** patch ***

pushd ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version} > /dev/null

cp app/models/repository.rb app/models/repository.rb.$(date '+%Y%m%d')
mv app/models/repository/subversion.rb app/models/repository/subversion.rb.$(date '+%Y%m%d')
cp ${OPENSHIFT_DATA_DIR}/github/openshift/app01/subversion.rb app/models/repository/

# リビジョンが大きくても日時が古いことがある...
perl -pi -e 's/#{Changeset.table_name}.committed_on DESC/CONVERT(#{Changeset.table_name}.revision, UNSIGNED) DESC/g' \
 app/models/repository.rb

cp config/environments/production.rb config/environments/production.rb.$(date '+%Y%m%d')
sed -i -e "s|^end$||g" config/environments/production.rb
cat << '__HEREDOC__' >> config/environments/production.rb
  config.logger = Logger.new('__OPENSHIFT_LOG_DIR__production.log', 'daily')
  config.logger.level = Logger::WARN
end
__HEREDOC__
sed -i -e "s|__OPENSHIFT_LOG_DIR__|${OPENSHIFT_LOG_DIR}|g" config/environments/production.rb
# https://www.loggly.com/docs/ruby-logs/

cp config/application.rb config/application.rb.$(date '+%Y%m%d')
perl -pi -e 's/^( +)(config.encoding.+)$/$1$2\r\n$1config.colorize_logging = false/g' \
 config/application.rb
ruby -cw config/application.rb
diff -u config/application.rb.$(date '+%Y%m%d') config/application.rb

popd > /dev/null

# *** create database ***

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

cat << '__HEREDOC__' > create_database_redmine.txt
DROP DATABASE IF EXISTS redmine;
CREATE DATABASE redmine CHARACTER SET utf8 COLLATE utf8_general_ci;
EXIT
__HEREDOC__

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
 --password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
 -h "${OPENSHIFT_MYSQL_DB_HOST}" \
 -P "${OPENSHIFT_MYSQL_DB_PORT}" < create_database_redmine.txt

popd > /dev/null

# * config database *

pushd ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version} > /dev/null
cat << '__HEREDOC__' > config/database.yml
production:
  adapter: mysql2
  database: redmine
  host: <%= ENV['OPENSHIFT_MYSQL_DB_HOST'] %>
  username: <%= ENV['OPENSHIFT_MYSQL_DB_USERNAME'] %>
  password: <%= ENV['OPENSHIFT_MYSQL_DB_PASSWORD'] %>
  port: <%= ENV['OPENSHIFT_MYSQL_DB_PORT'] %>
  encoding: utf8
__HEREDOC__

# *** config mail font ***

cat << '__HEREDOC__' > config/configuration.yml
default:
  email_delivery:
    delivery_method: :smtp
    smtp_settings:
      address: smtp.mail.yahoo.co.jp
      port: 587
      domain: yahoo.co.jp
      authentication: :plain
      user_name: "__USER_NAME__" 
      password: "__PASSWORD__" 

rmagick_font_path: <%= ENV['OPENSHIFT_DATA_DIR'] %>/fonts/ipagp.ttf
__HEREDOC__

redmine_email_address=$(cat ${OPENSHIFT_DATA_DIR}/params/redmine_email_address)
redmine_email_password=$(cat ${OPENSHIFT_DATA_DIR}/params/redmine_email_password)

sed -i -e "s/__USER_NAME__/${redmine_email_address}/g" config/configuration.yml
perl -pi -e "s/__PASSWORD__/${redmine_email_password}/g" config/configuration.yml

# *** plugin_assets ***
mkdir public/plugin_assets

popd > /dev/null

# *** plugin ***
pushd ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/plugins > /dev/null
# cp ${OPENSHIFT_DATA_DIR}/download_files/redmine_logs-0.0.5.zip ./
# unzip redmine_logs-0.0.5.zip
# rm redmine_logs-0.0.5.zip
# mv redmine_logs/Gemfile redmine_logs/Gemfile.org
popd > /dev/null

# *** ruby env ***

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"

rbenv local ${ruby_version}
rbenv rehash

tmp_string=$(echo ${DISTCC_HOSTS} | sed -e "s|/4:|/1:|g")
export DISTCC_HOSTS="${tmp_string}"

# ***** debug code ******

mkdir -p ${OPENSHIFT_TMP_DIR}/local2/bin
cat << '__HEREDOC__' > ${OPENSHIFT_TMP_DIR}/local2/bin/gcc
#!/bin/bash
export TZ=JST-9
echo "$(date +%Y/%m/%d" "%H:%M:%S) $@" >> ${OPENSHIFT_LOG_DIR}/gcc_bundle.log
/usr/bin/gcc $@
__HEREDOC__
chmod +x ${OPENSHIFT_TMP_DIR}/local2/bin/gcc
export PATH="${OPENSHIFT_TMP_DIR}/local2/bin:$PATH"

# *** bundle ***

echo "$(date +%Y/%m/%d" "%H:%M:%S) redmine bundle install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

pushd ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version} > /dev/null
mv Gemfile Gemfile.$(date '+%Y%m%d')
cp ${OPENSHIFT_DATA_DIR}/download_files/Gemfile_redmine_custom ./Gemfile
bundle config build.activerecord --with-cflags="${CFLAGS}" --local
bundle config build.rails --with-cflags="${CFLAGS}" --local
bundle config build.rake --with-cflags="${CFLAGS}" --local
bundle config build.mysql2 --with-cflags="${CFLAGS}" --local
bundle config --local 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
mkdir .bundle
cat << '__HEREDOC__' > .bundle/config
---
BUNDLE_BUILD__ACTIVERECORD: --with-cflags='__CFLAGS__'
BUNDLE_BUILD__RAILS: --with-cflags='__CFLAGS__'
BUNDLE_BUILD__RAKE: --with-cflags='__CFLAGS__'
BUNDLE_BUILD__MYSQL2: --with-cflags='__CFLAGS__'
BUNDLE_BUILD__JQUERY_RAILS: --with-cflags='__CFLAGS__'
BUNDLE_BUILD__CODERAY: --with-cflags='__CFLAGS__'
BUNDLE_BUILD__REQUEST_STORE: --with-cflags='__CFLAGS__'
__HEREDOC__
sed -i -e "s|__CFLAGS__|${CFLAGS}|g" .bundle/config
pushd ${OPENSHIFT_DATA_DIR}/distcc/bin > /dev/null
ln -s distcc cc
ln -s distcc gcc
ln -s distcc c++
ln -s distcc g++
popd > /dev/null
# time bundle install --no-color --path vendor/bundle --without=test development --verbose \
#  --jobs=$(grep -c -e processor /proc/cpuinfo) --retry=5 \
#  >${OPENSHIFT_LOG_DIR}/bundle.install.log 2>&1
time bundle install --no-color --path vendor/bundle --without=test development --verbose \
 --jobs=6 --retry=5 \
 >${OPENSHIFT_LOG_DIR}/bundle.install.log 2>&1
pushd ${OPENSHIFT_DATA_DIR}/distcc/bin > /dev/null
unlink cc
unlink gcc
unlink c++
unlink g++
popd > /dev/null
mv ${OPENSHIFT_LOG_DIR}/bundle.install.log ${OPENSHIFT_LOG_DIR}/install/
bundle show | tee -a ${OPENSHIFT_LOG_DIR}/install.log
cat .bundle/config | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# *** rake ***

echo "$(date +%Y/%m/%d" "%H:%M:%S) redmine rake" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

time RAILS_ENV=production bundle exec rake generate_secret_token 2>&1 \
 | tee ${OPENSHIFT_LOG_DIR}/generate_secret_token.rake.log
mv ${OPENSHIFT_LOG_DIR}/generate_secret_token.rake.log ${OPENSHIFT_LOG_DIR}/install/
time RAILS_ENV=production bundle exec rake db:migrate 2>&1 \
 | tee ${OPENSHIFT_LOG_DIR}/db_migrate.rake.log
mv ${OPENSHIFT_LOG_DIR}/db_migrate.rake.log ${OPENSHIFT_LOG_DIR}/install/
time RAILS_ENV=production bundle exec rake redmine:plugins:migrate 2>&1 \
 | tee ${OPENSHIFT_LOG_DIR}/redmine_plugins_migrate.rake.log
mv ${OPENSHIFT_LOG_DIR}/redmine_plugins_migrate.rake.log ${OPENSHIFT_LOG_DIR}/install/

# *** database table format compact -> compress ***

function020 redmine

# *** coderay bash ***

find ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/vendor/bundle/ruby/ -name scanners -type d \
 | grep /lib/coderay/scanners \
 | xargs -i cp ${OPENSHIFT_DATA_DIR}/download_files/bash.rb {}/

find ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/vendor/bundle/ruby/ -name file_type.rb -type f -print0 \
 | xargs -0i cp -f {} ${OPENSHIFT_TMP_DIR}

find ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/vendor/bundle/ruby/ -name file_type.rb -type f \
 | grep coderay/helpers/ \
 | xargs perl -pi -e 's/(TypeFromExt = {)$/$1\012    \x27bash\x27 => :bash,\012/g'

echo "$(date +%Y/%m/%d" "%H:%M:%S) bash.rb copy check" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
find ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/vendor/bundle/ruby/ -name bash.rb -type f \
 >> ${OPENSHIFT_LOG_DIR}/install.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) file_types.rb diff" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
find ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/vendor/bundle/ruby/ -name file_type.rb -type f -print0 \
 | xargs -0i diff -u ${OPENSHIFT_TMP_DIR}/file_type.rb {}
echo "$(date +%Y/%m/%d" "%H:%M:%S) file_types.rb syntax check" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
find ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/vendor/bundle/ruby/ -name file_type.rb -type f -print0 \
 | xargs -0i ruby -cw {}

popd > /dev/null

# *** apache conf ***

echo >> ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf
cat ${OPENSHIFT_TMP_DIR}/passenger.conf >> ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf

cat << '__HEREDOC__' >> ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf
RailsBaseURI /redmine
PassengerBaseURI /redmine
# PassengerTempDir __OPENSHIFT_DATA_DIR__tmp
# too long unix socket path (max: 107bytes)
# PassengerTempDir __OPENSHIFT_TMP_DIR__PassengerTempDir
# Invalid command 'PassengerTempDir', perhaps misspelled or defined by a module not included in the server configuration
SetEnv GEM_HOME __OPENSHIFT_DATA_DIR__.gem
# TODO
# SetEnv GEM_PATH

RailsMaxPoolSize 2
RailsPoolIdleTime 7200
PassengerEnabled off
PassengerStatThrottleRate 5
PassengerStartTimeout 300
PassengerFriendlyErrorPages off
# RailsAutoDetect off

<Location "/redmine">
  PassengerEnabled on
</Location>

# PassengerPreStart http://__OPENSHIFT_APP_DNS__/redmine/
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf
perl -pi -e 's/__OPENSHIFT_APP_DNS__/$ENV{OPENSHIFT_APP_DNS}/g' ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf
perl -pi -e 's/__OPENSHIFT_TMP_DIR__/$ENV{OPENSHIFT_TMP_DIR}/g' ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf

echo "$(date +%Y/%m/%d" "%H:%M:%S) apache configtest" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
${OPENSHIFT_DATA_DIR}/apache/bin/apachectl configtest | tee -a ${OPENSHIFT_LOG_DIR}/install.log

mkdir ${OPENSHIFT_TMP_DIR}/PassengerTempDir

# *** apache link ***

ln -s ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/public ${OPENSHIFT_DATA_DIR}/apache/htdocs/redmine

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/system > /dev/null
cat << '__HEREDOC__' > redmine.php
<?php
touch(getenve('OPENSHIFT_DATA_DIR') + '/redmine-__REDMINE_VERSION__/tmp/restart.txt')
?>
__HEREDOC__
perl -pi -e 's/__REDMINE_VERSION__/${redmine_version}/g' redmine.php
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
