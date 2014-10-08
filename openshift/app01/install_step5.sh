#!/bin/bash

set -x

while read LINE
do
  product=`echo $LINE | awk '{print $1}'`
  version=`echo $LINE | awk '{print $2}'`
  eval "$product"=$version
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 5 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** restart *****

/usr/bin/gear restart --all-cartridges

# ***** etc *****

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"

${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module --snippet > ${OPENSHIFT_TMP_DIR}/passenger.conf

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

echo `date +%Y/%m/%d" "%H:%M:%S` request_handler.rb patch check >> ${OPENSHIFT_LOG_DIR}/install.log
find ${OPENSHIFT_DATA_DIR} -name request_handler.rb -type f \
| grep lib/phusion_passenger/request_handler.rb \
| xargs cat \
| grep ${OPENSHIFT_DIY_IP} >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** font *****

echo `date +%Y/%m/%d" "%H:%M:%S` font install >> ${OPENSHIFT_LOG_DIR}/install.log

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
# cp ${OPENSHIFT_DATA_DIR}/download_files/IPAfont${ipafont_version}.zip ./
# unzip -d fonts -j IPAfont${ipafont_version}.zip
# rm IPAfont${ipafont_version}.zip
cp ${OPENSHIFT_DATA_DIR}/download_files/ipagp${ipafont_version}.zip ./
unzip -d fonts -j ipagp${ipafont_version}.zip
rm ipagp${ipafont_version}.zip

# ***** redmine *****

echo `date +%Y/%m/%d" "%H:%M:%S` redmine install >> ${OPENSHIFT_LOG_DIR}/install.log

# *** redmine ***

cd ${OPENSHIFT_DATA_DIR}
cp ${OPENSHIFT_DATA_DIR}/download_files/redmine-${redmine_version}.tar.gz ./
tar xfz redmine-${redmine_version}.tar.gz

# *** patch ***
# TODO
# app\models\repository\subversion.rb
# while (identifier_from <= scm_revision) → if identifier_from <= scm_revision
perl -pi -e 's/(^        while \(identifier_from <= scm_revision\)$)/$1\r\n        if identifier_from <= scm_revision/g' app/models/repository/subversion.rb

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

pushd ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}
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

# *** plugin_assets ***
mkdir public/plugin_assets

popd > /dev/null

# *** plugin ***
pushd plugins > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/redmine_logs-0.0.5.zip ./
unzip redmine_logs-0.0.5.zip
rm redmine_logs-0.0.5.zip
mv redmine_logs/Gemfile redmine_logs/Gemfile.org
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

pushd ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}
mv Gemfile Gemfile.`date '+%Y%m%d'`
cp ${OPENSHIFT_DATA_DIR}/download_files/Gemfile_redmine_custom ./Gemfile
time bundle install --path vendor/bundle -j2

# *** rake ***

time RAILS_ENV=production bundle exec rake generate_secret_token
time RAILS_ENV=production bundle exec rake db:migrate
time RAILS_ENV=production bundle exec rake redmine:plugins:migrate

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

# *** add log link ***

# ログプラグインで見られるようにする

# * cron *

if [ ! -f ${OPENSHIFT_LOG_DIR}/cron_monthly.log ]; then
    touch ${OPENSHIFT_LOG_DIR}/cron_monthly.log
fi
if [ ! -f ${OPENSHIFT_LOG_DIR}/cron_weekly.log ]; then
    touch ${OPENSHIFT_LOG_DIR}/cron_weekly.log
fi
if [ ! -f ${OPENSHIFT_LOG_DIR}/cron_daily.log ]; then
    touch ${OPENSHIFT_LOG_DIR}/cron_daily.log
fi
if [ ! -f ${OPENSHIFT_LOG_DIR}/cron_hourly.log ]; then
    touch ${OPENSHIFT_LOG_DIR}/cron_hourly.log
fi
if [ ! -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log ]; then
    touch ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

# ln -f -s ${OPENSHIFT_LOG_DIR}/cron_daily.log log/cron_monthly.log
# ln -f -s ${OPENSHIFT_LOG_DIR}/cron_daily.log log/cron_weekly.log
# ln -f -s ${OPENSHIFT_LOG_DIR}/cron_daily.log log/cron_daily.log
# ln -f -s ${OPENSHIFT_LOG_DIR}/cron_hourly.log log/cron_hourly.log
# ln -f -s ${OPENSHIFT_LOG_DIR}/cron_minutely.log log/cron_minutely.log

# * apache *

# ln -f -s ${OPENSHIFT_DATA_DIR}/apache/log/access_log log/access_log
# ln -f -s ${OPENSHIFT_DATA_DIR}/apache/log/error_log log/error_log

popd > /dev/null

# *** apache conf ***

echo >> ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf
cat ${OPENSHIFT_TMP_DIR}/passenger.conf >> ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf

cat << '__HEREDOC__' >> ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf
RailsBaseURI /redmine
PassengerBaseURI /redmine
SetEnv GEM_HOME __OPENSHIFT_DATA_DIR__.gem

RailsMaxPoolSize 2
RailsPoolIdleTime 7200
PassengerEnabled off
PassengerStatThrottleRate 5
# RailsAutoDetect off

<Location "/redmine">
  PassengerEnabled on
</Location>
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' ${OPENSHIFT_DATA_DIR}/apache/conf/custom.conf

# *** apache link ***

ln -s ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/public ${OPENSHIFT_DATA_DIR}/apache/htdocs/redmine

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 5 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
