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
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 6 Start | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# ***** restart *****

/usr/bin/gear restart --all-cartridges

# ***** etc *****

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"

${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module --snippet > ${OPENSHIFT_TMP_DIR}/passenger.conf

# *** passenger patch ***

# patch request_handler.rb
# OPENSHIFT では 127.0.0.1 は使えないため ${OPENSHIFT_DIY_IP} に置換
# https://help.openshift.com/hc/en-us/articles/202185874
# 15000 - 35530
find ${OPENSHIFT_DATA_DIR} -name request_handler.rb -type f \
| grep lib/phusion_passenger/request_handler.rb \
| xargs perl -pi -e "s/new\(\'127.0.0.1\', 0\)/new(\'${OPENSHIFT_DIY_IP}\', rand(15000..20000))/g"

find ${OPENSHIFT_DATA_DIR} -name request_handler.rb -type f \
| grep lib/phusion_passenger/request_handler.rb \
| xargs perl -pi -e 's/127.0.0.1/$ENV{OPENSHIFT_DIY_IP}/g'

# *** patch check ***

echo `date +%Y/%m/%d" "%H:%M:%S` request_handler.rb patch check | tee -a ${OPENSHIFT_LOG_DIR}/install.log
find ${OPENSHIFT_DATA_DIR} -name request_handler.rb -type f \
| grep lib/phusion_passenger/request_handler.rb \
| xargs cat \
| grep ${OPENSHIFT_DIY_IP} >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** font *****

echo `date +%Y/%m/%d" "%H:%M:%S` font install | tee -a ${OPENSHIFT_LOG_DIR}/install.log

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
# cp ${OPENSHIFT_DATA_DIR}/download_files/IPAfont${ipafont_version}.zip ./
# unzip -d fonts -j IPAfont${ipafont_version}.zip
# rm IPAfont${ipafont_version}.zip
cp ${OPENSHIFT_DATA_DIR}/download_files/ipagp${ipafont_version}.zip ./
unzip -d fonts -j ipagp${ipafont_version}.zip
rm ipagp${ipafont_version}.zip
popd > /dev/null

# ***** redmine *****

echo `date +%Y/%m/%d" "%H:%M:%S` redmine install | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# *** redmine ***

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/redmine-${redmine_version}.tar.gz ./
tar xfz redmine-${redmine_version}.tar.gz
rm redmine-${redmine_version}.tar.gz
popd > /dev/null

# *** patch ***

pushd ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version} > /dev/null

cp app/models/repository.rb app/models/repository.rb.org
mv app/models/repository/subversion.rb app/models/repository/subversion.rb.org
cp ${OPENSHIFT_DATA_DIR}/github/openshift/app01/subversion.rb app/models/repository/

# リビジョンが大きくても日時が古いことがある
perl -pi -e 's/#{Changeset.table_name}.committed_on DESC/CONVERT(#{Changeset.table_name}.revision, UNSIGNED) DESC/g' app/models/repository.rb

popd > /dev/null

# *** create database ***

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

cat << '__HEREDOC__' > create_database_redmine.txt
CREATE DATABASE redmine CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON redmine.* TO redmineuser@__OPENSHIFT_MYSQL_DB_HOST__ IDENTIFIED BY '__PASSWORD__';
FLUSH PRIVILEGES;
EXIT
__HEREDOC__

# * create password *

redmineuser_password=`uuidgen | base64 | head -c 25`
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' create_database_redmine.txt
perl -pi -e "s/__PASSWORD__/${redmineuser_password}/g" create_database_redmine.txt

# * create database *

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
  username: redmineuser
  password: __PASSWORD__
  port: <%= ENV['OPENSHIFT_MYSQL_DB_PORT'] %>
  encoding: utf8
__HEREDOC__
perl -pi -e "s/__PASSWORD__/${redmineuser_password}/g" config/database.yml

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

redmine_email_address=`cat ${OPENSHIFT_DATA_DIR}/redmine_email_address`
redmine_email_password=`cat ${OPENSHIFT_DATA_DIR}/redmine_email_password`

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

# *** bundle ***

pushd ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version} > /dev/null
mv Gemfile Gemfile.`date '+%Y%m%d'`
cp ${OPENSHIFT_DATA_DIR}/download_files/Gemfile_redmine_custom ./Gemfile
time bundle install --path vendor/bundle -j2 >${OPENSHIFT_LOG_DIR}/bundle.install.log 2>&1

# *** rake ***

time RAILS_ENV=production bundle exec rake generate_secret_token 2>&1 | tee ${OPENSHIFT_LOG_DIR}/generate_secret_token.rake.log
time RAILS_ENV=production bundle exec rake db:migrate 2>&1 | tee ${OPENSHIFT_LOG_DIR}/db_migrate.rake.log
time RAILS_ENV=production bundle exec rake redmine:plugins:migrate 2>&1 | tee ${OPENSHIFT_LOG_DIR}/redmine_plugins_migrate.rake.log

# *** coderay bash ***

find ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/vendor/bundle/ruby/ -name scanners -type d \
| grep /lib/coderay/scanners \
| xargs -I{} cp ${OPENSHIFT_DATA_DIR}/download_files/bash.rb {}/

find ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/vendor/bundle/ruby/ -name file_type.rb -type f \
| grep coderay/helpers/ \
| xargs perl -pi -e 's/(TypeFromExt = {)$/$1\012    \x27bash\x27 => :bash,\012/g'

echo `date +%Y/%m/%d" "%H:%M:%S` bash.rb copy check >> ${OPENSHIFT_LOG_DIR}/install.log
find ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/vendor/bundle/ruby/ -name bash.rb -type f >> ${OPENSHIFT_LOG_DIR}/install.log

echo `date +%Y/%m/%d" "%H:%M:%S` file_types.rb patch check >> ${OPENSHIFT_LOG_DIR}/install.log
find ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/vendor/bundle/ruby/ -name file_type.rb -type f | xargs cat | grep bash >> ${OPENSHIFT_LOG_DIR}/install.log

popd > /dev/null

# *** apache conf ***

echo >> ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf
cat ${OPENSHIFT_TMP_DIR}/passenger.conf >> ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf

cat << '__HEREDOC__' >> ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf
RailsBaseURI /redmine
PassengerBaseURI /redmine
PassengerTempDir __OPENSHIFT_DATA_DIR__tmp
SetEnv GEM_HOME __OPENSHIFT_DATA_DIR__.gem
# TODO
# SetEnv GEM_PATH

RailsMaxPoolSize 2
RailsPoolIdleTime 7200
PassengerEnabled off
PassengerStatThrottleRate 5
PassengerFriendlyErrorPages off
# RailsAutoDetect off

<Location "/redmine">
  PassengerEnabled on
</Location>

# PassengerPreStart http://__OPENSHIFT_APP_DNS__/redmine/
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf
perl -pi -e 's/__OPENSHIFT_APP_DNS__/$ENV{OPENSHIFT_APP_DNS}/g' ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf

# *** apache link ***

ln -s ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/public ${OPENSHIFT_DATA_DIR}/apache/htdocs/redmine

pushd ${OPENSHIFT_DATA_DIR}/var/www/cgi-bin > /dev/null
cat << '__HEREDOC__' > restart_redmine.cgi
#!/usr/bin/perl

system("touch __OPENSHIFT_DATA_DIR__/redmine-__REDMINE_VERSION__/tmp/restart.txt")

exit;
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' restart_redmine.cgi
perl -pi -e 's/__REDMINE_VERSION__/${redmine_version}/g' restart_redmine.cgi
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 6 Finish | tee -a ${OPENSHIFT_LOG_DIR}/install.log
