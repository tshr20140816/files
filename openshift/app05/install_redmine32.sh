#!/bin/bash

export TZ=JST-9
set -x
quota -s
oo-cgroup-read memory.usage_in_bytes
oo-cgroup-read memory.failcnt

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

# ***** distcc *****

distcc_version="3.1"

cd ${OPENSHIFT_TMP_DIR}
wget -q https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2
tar jxf distcc-${distcc_version}.tar.bz2
cd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version}
# ./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/usr \
 --infodir=${OPENSHIFT_TMP_DIR}/gomi \
 --mandir=${OPENSHIFT_TMP_DIR}/gomi
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
cd ${OPENSHIFT_TMP_DIR}
rm -rf distcc-${distcc_version}
rm -f distcc-${distcc_version}.tar.bz2

mkdir ${OPENSHIFT_DATA_DIR}/.distcc

export PATH="${OPENSHIFT_DATA_DIR}/usr/bin:$PATH"
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
# export DISTCC_LOG=/dev/null
export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc.log

# ***** distcc hosts *****

if [ -e ${OPENSHIFT_DATA_DIR}/params/distcc_hosts.txt ]; then
    tmp_string="$(cat ${OPENSHIFT_DATA_DIR}/params/distcc_hosts.txt)"
    export DISTCC_HOSTS="${tmp_string}"
    export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"
    export CC="distcc gcc"
    export CXX="distcc g++"
fi

# ***** apache *****

apache_version="2.2.31"

# *** install ***

cd ${OPENSHIFT_TMP_DIR}
wget -q http://ftp.riken.jp/net/apache//httpd/httpd-${apache_version}.tar.bz2
tar xf httpd-${apache_version}.tar.bz2
rm -f httpd-${apache_version}.tar.bz2
cd httpd-${apache_version}
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr \
 --mandir=${OPENSHIFT_TMP_DIR}/gomi \
 --docdir=${OPENSHIFT_TMP_DIR}/gomi \
 --infodir=${OPENSHIFT_TMP_DIR}/gomi \
 --enable-mods-shared='all proxy' \
 --disable-authn-anon \
 --disable-authn-dbd \
 --disable-authn-dbm \
 --disable-authz-dbm \
 --disable-authz-groupfile \
 --disable-dbd \
 --disable-imagemap \
 --disable-include \
 --disable-info \
 --disable-log-forensic \
 --disable-proxy-ajp \
 --disable-proxy-balancer \
 --disable-proxy-ftp \
 --disable-proxy-scgi
 --disable-speling \
 --disable-status \
 --disable-userdir \
 --disable-version \
 --disable-vhost-alias
time make -j4
make install
rm -rf ${OPENSHIFT_DATA_DIR}/usr/manual
cd ${OPENSHIFT_TMP_DIR}
rm -rf httpd-${apache_version}

# *** conf ***

cd ${OPENSHIFT_DATA_DIR}/usr/conf
cp httpd.conf httpd.conf.$(date '+%Y%m%d')

perl -pi -e 's/^Listen .+$/Listen $ENV{OPENSHIFT_DIY_IP}:8080/g' httpd.conf
perl -pi -e 's/AllowOverride None/AllowOverride All/g' httpd.conf

cat << '__HEREDOC__' >> httpd.conf

Include conf/custom.conf
__HEREDOC__

perl -pi -e 's/(^LoadModule.+mod_authn_anon.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_authn_dbm.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_authz_dbm.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_authz_groupfile.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_authz_owner.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_info.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_proxy_balancer.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_proxy_ftp.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_speling.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_status.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_userdir.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_version.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_vhost_alias.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_authn_dbd.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_dbd.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_log_forensic.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_proxy_ajp.so$)/# $1/g' httpd.conf
perl -pi -e 's/(^LoadModule.+mod_proxy_scgi.so$)/# $1/g' httpd.conf

perl -pi -e 's/(^ *LogFormat.+$)/# $1/g' httpd.conf
perl -pi -e 's/(^ *CustomLog.+$)/# $1/g' httpd.conf
perl -pi -e 's/(^ *ErrorLog.+$)/# $1/g' httpd.conf

cat << '__HEREDOC__' > custom.conf
# tune

MinSpareServers 1
MaxSpareServers 2
StartServers 1
KeepAlive On
Timeout 60
LanguagePriority ja en

# log

DeflateFilterNote ratio

LogFormat "%{X-Client-IP}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "[%{%Y-%m-%d %H:%M:%S %Z}t] %p %{X-Client-IP}i %{X-Forwarded-For}i %l %m %s %b \"%r\" \"%{User-Agent}i\"" remoteip
LogFormat "[%{%Y-%m-%d %H:%M:%S %Z}t] %X %>s %b %{ratio}n%% %D \"%r\"" deflate

SetEnvIf Request_Method (HEAD|OPTIONS) no_log_1
SetEnvIf Request_Method (HEAD|OPTIONS) no_log_2
SetEnvIf Request_URI "\.gif$" no_log_2
SetEnvIf Request_URI "\.png$" no_log_2

CustomLog \
 "|/usr/sbin/rotatelogs -L __APACHE_DIR__logs/access_log __APACHE_DIR__logs/access_log.%w 86400 540" combined
CustomLog \
 "|/usr/sbin/rotatelogs -L __APACHE_DIR__logs/access_remoteip_log __APACHE_DIR__logs/access_remoteip_log.%w 86400 540" \
 remoteip env=!no_log_1
CustomLog \
 "|/usr/sbin/rotatelogs -L __APACHE_DIR__logs/access_deflate_log __APACHE_DIR__logs/access_deflate_log.%w 86400 540" \
 deflate env=!no_log_2

ErrorLog \
 "|/usr/sbin/rotatelogs -L __APACHE_DIR__logs/error_log __APACHE_DIR__logs/error_log.%w 86400 540"

# indexes

IndexOptions +NameWidth=*

# security

ServerTokens Prod

HostnameLookups Off
UseCanonicalName Off
AccessFileName .htaccess
TraceEnable Off

Header always unset X-Powered-By
Header always unset X-Rack-Cache
Header always unset X-Runtime

# force ssl

<IfModule mod_rewrite.c>
    RewriteEngine on
    RewriteLog \
     "|/usr/sbin/rotatelogs -L __APACHE_DIR__logs/rewrite_log __APACHE_DIR__logs/rewrite_log.%w 86400 540"
    RewriteLogLevel 1
    RewriteCond %{HTTP:X-Forwarded-Proto} !https
    RewriteRule .* https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
</IfModule>

__HEREDOC__

# *** robots ***

cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/usr/htdocs/robots.txt
User-agent: *
Disallow: /
__HEREDOC__

# ***** ruby *****

ruby_version="2.3.1"

rm -rf ${OPENSHIFT_DATA_DIR}.gem
rm -rf ${OPENSHIFT_DATA_DIR}.rbenv

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem

cd ${OPENSHIFT_TMP_DIR}

wget -q https://raw.github.com/Seppone/openshift-rbenv-installer/master/bin/rbenv-installer

bash rbenv-installer
rm rbenv-installer

export RBENV_ROOT="${OPENSHIFT_DATA_DIR}/.rbenv"
[ $(echo $PATH | grep -c ${OPENSHIFT_DATA_DIR}/.rbenv/bin) -eq 0 ] && export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
[ $(echo $PATH | grep -c ${OPENSHIFT_DATA_DIR}/.gem/bin) -eq 0 ] && export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"

time CONFIGURE_OPTS="--disable-install-doc --mandir=${OPENSHIFT_TMP_DIR}/gomi --docdir=${OPENSHIFT_TMP_DIR}/gomi" \
 RUBY_CONFIGURE_OPTS="--with-out-ext=tk,tk/*" \
 MAKE_OPTS="-j $(grep -c -e processor /proc/cpuinfo)" \
 rbenv install -v ${ruby_version}

rbenv global ${ruby_version}
rbenv rehash
ruby -v

# *** patch resolv.rb ***

find ${OPENSHIFT_DATA_DIR}/.rbenv/versions/ -name resolv.rb -type f -print0 \
 | xargs -0 perl -pi -e "s/0\.0\.0\.0/${OPENSHIFT_DIY_IP}/g"

cd ${OPENSHIFT_TMP_DIR}

for gem in bundler rack passenger
do
    rm -f ${gem}.html
    wget -q https://rubygems.org/gems/${gem} -O ${gem}.html
    version=$(grep -e canonical ${gem}.html | sed -r -e 's|^.*versions/(.+)".*$|\1|g')
    wget -q https://rubygems.org/downloads/${gem}-${version}.gem -O ${gem}-${version}.gem
    time rbenv exec gem install --local ${gem}-${version}.gem --no-rdoc --no-ri
    rbenv rehash
    rm -f ${gem}.html
    rm -f ${gem}-${version}.gem
done

# ***** passenger-install-apache2-module *****

home_org=${HOME}
export HOME=${OPENSHIFT_DATA_DIR}
# export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
# export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
eval "$(rbenv init -)"
# export PATH=${OPENSHIFT_DATA_DIR}/usr/bin:$PATH

# mkdir -p ${OPENSHIFT_DATA_DIR}/usr/bin
cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/usr/bin/c++
#!/bin/bash

while :
do
    usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
    if [ "${usage_in_bytes}" -lt 500000000 ]; then
        break
    fi
    dt=$(date +%H%M%S)
    usage_in_bytes_format=$(echo "${usage_in_bytes}" | awk '{printf "%\047d\n", $0}')
    failcnt=$(oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $0}')
    echo "$dt $usage_in_bytes_format $failcnt"
    # ps alx --sort -rss | head -n 3
    if [ "${usage_in_bytes}" -gt 500000000 ]; then
        pushd "${OPENSHIFT_TMP_DIR}" > /dev/null
        if [ "$(find ./ -type f -mmin -3 -name execute -print | wc -l)" -eq 0 ]; then
            # sumanu
            wget -q http://mirrors.kernel.org/gnu/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2
            rm -f gcc-5.3.0.tar.bz2
            touch execute
        fi
        popd > /dev/null
    fi
    sleep 60s
done

set -x
/usr/bin/c++ "$@"
__HEREDOC__
chmod +x ${OPENSHIFT_DATA_DIR}/usr/bin/c++

cd ${OPENSHIFT_TMP_DIR}

time ${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module \
 --auto \
 --languages ruby \
 --apxs2-path ${OPENSHIFT_DATA_DIR}/usr/bin/apxs

rm -f ${OPENSHIFT_DATA_DIR}/usr/bin/c++
export HOME=${home_org}

# *** patch ***

find ${OPENSHIFT_DATA_DIR} -name request_handler.rb -type f \
 | grep -e lib/phusion_passenger/request_handler.rb \
 | xargs perl -pi -e "s/new\(\'127.0.0.1\', 0\)/new(\'${OPENSHIFT_DIY_IP}\', 25777)/g"

find ${OPENSHIFT_DATA_DIR} -name request_handler.rb -type f \
 | grep -e lib/phusion_passenger/request_handler.rb \
 | xargs perl -pi -e 's/127.0.0.1/$ENV{OPENSHIFT_DIY_IP}/g'

${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module --snippet > ${OPENSHIFT_TMP_DIR}/passenger.conf
cat ${OPENSHIFT_TMP_DIR}/passenger.conf >> ${OPENSHIFT_DATA_DIR}/usr/conf/custom.conf
rm -f ${OPENSHIFT_TMP_DIR}/passenger.conf

# ***** redmine *****

redmine_version=3.2.2

cd ${OPENSHIFT_DATA_DIR}

wget -q https://www.redmine.org/releases/redmine-${redmine_version}.tar.gz
tar xf redmine-${redmine_version}.tar.gz
rm redmine-${redmine_version}.tar.gz

# *** patch ***

cd redmine-${redmine_version}
cp config/application.rb config/application.rb.$(date '+%Y%m%d')
perl -pi -e 's/^( +)(config.encoding.+)$/$1$2\r\n$1config.colorize_logging = false/g' config/application.rb

# *** create database ***

cd ${OPENSHIFT_TMP_DIR}
cat << '__HEREDOC__' > create_database_redmine.txt
DROP DATABASE IF EXISTS redmine;
CREATE DATABASE redmine CHARACTER SET utf8 COLLATE utf8_general_ci;
EXIT
__HEREDOC__

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
 --password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
 -h "${OPENSHIFT_MYSQL_DB_HOST}" \
 -P "${OPENSHIFT_MYSQL_DB_PORT}" < create_database_redmine.txt

cd ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}

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

# *** plugin_assets ***

mkdir public/plugin_assets

# *** ruby env ***

# export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
# export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
eval "$(rbenv init -)"

rbenv local ${ruby_version}
rbenv rehash

# *** bundle ***

cd ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}
mv Gemfile Gemfile.$(date '+%Y%m%d')
cat << '__HEREDOC__' > Gemfile
# Thanks http://d.hatena.ne.jp/suu-g/20130908/1378623978
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

if Gem::Version.new(Bundler::VERSION) < Gem::Version.new('1.5.0')
  abort "Redmine requires Bundler 1.5.0 or higher (you're using #{Bundler::VERSION}).\nPlease update with 'gem update bundler'."
end

gem "rails", "4.2.5.2"
gem "jquery-rails", "~> 3.1.4"
gem "coderay", "~> 1.1.0"
gem "builder", ">= 3.0.4"
gem "request_store", "1.0.5"
gem "mime-types"
gem "protected_attributes"
gem "actionpack-action_caching"
gem "actionpack-xml_parser"
gem "roadie-rails"
gem "mimemagic"

# Request at least nokogiri 1.6.7.2 because of security advisories
gem "nokogiri", ">= 1.6.7.2"

# Request at least rails-html-sanitizer 1.0.3 because of security advisories
gem "rails-html-sanitizer", ">= 1.0.3"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :x64_mingw, :mswin, :jruby]
gem "rbpdf", "~> 1.19.0"

# Optional gem for OpenID authentication
group :openid do
  gem "ruby-openid", "~> 2.3.0", :require => "openid"
  gem "rack-openid"
end

platforms :mri, :mingw, :x64_mingw do
  # Optional gem for exporting the gantt to a PNG file, not supported with jruby
  group :rmagick do
    gem "rmagick", ">= 2.14.0"
  end

  # Optional Markdown support, not for JRuby
  group :markdown do
    gem "redcarpet", "~> 3.3.2"
  end
end

platforms :jruby do
  # jruby-openssl is bundled with JRuby 1.7.0
  gem "jruby-openssl" if Object.const_defined?(:JRUBY_VERSION) && JRUBY_VERSION < '1.7.0'
  gem "activerecord-jdbc-adapter", "~> 1.3.2"
end

# Include database gems for the adapters found in the database
# configuration file
require 'erb'
require 'yaml'

gem "mysql2", "~> 0.3.11"
gem "activerecord-jdbcmysql-adapter", :platforms => :jruby

local_gemfile = File.join(File.dirname(__FILE__), "Gemfile.local")
if File.exists?(local_gemfile)
  eval_gemfile local_gemfile
end

# Load plugins' Gemfiles
Dir.glob File.expand_path("../plugins/*/{Gemfile,PluginGemfile}", __FILE__) do |file|
  eval_gemfile file
end
__HEREDOC__

bundle config build.activerecord --local
bundle config build.rails --local
bundle config build.rake --local
bundle config build.mysql2 --local
bundle config --local

mkdir .bundle
touch .bundle/config

time bundle install --no-color --path vendor/bundle --without=test development --verbose --jobs=1 --retry=5

time RAILS_ENV=production bundle exec rake generate_secret_token
time RAILS_ENV=production bundle exec rake db:migrate
time RAILS_ENV=production bundle exec rake redmine:plugins:migrate

# *** apache conf ***

cat << '__HEREDOC__' >> ${OPENSHIFT_DATA_DIR}/usr/conf/custom.conf

PassengerLogFile __OPENSHIFT_LOG_DIR__passenger.log
RailsBaseURI /redmine
PassengerBaseURI /redmine
SetEnv GEM_HOME __OPENSHIFT_DATA_DIR__.gem

RailsMaxPoolSize 2
RailsPoolIdleTime 7200
PassengerEnabled off
PassengerStatThrottleRate 5
PassengerStartTimeout 300
PassengerFriendlyErrorPages off

<Location "/redmine">
  PassengerEnabled on
</Location>

__HEREDOC__

perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' ${OPENSHIFT_DATA_DIR}/usr/conf/custom.conf
perl -pi -e 's/__OPENSHIFT_APP_DNS__/$ENV{OPENSHIFT_APP_DNS}/g' ${OPENSHIFT_DATA_DIR}/usr/conf/custom.conf
perl -pi -e 's/__OPENSHIFT_TMP_DIR__/$ENV{OPENSHIFT_TMP_DIR}/g' ${OPENSHIFT_DATA_DIR}/usr/conf/custom.conf
perl -pi -e 's/__OPENSHIFT_LOG_DIR__/$ENV{OPENSHIFT_LOG_DIR}/g' ${OPENSHIFT_DATA_DIR}/usr/conf/custom.conf

mkdir ${OPENSHIFT_TMP_DIR}/PassengerTempDir

ln -s ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/public ${OPENSHIFT_DATA_DIR}/usr/htdocs/redmine

rm -rf ${OPENSHIFT_TMP_DIR}/gomi

# ***** restart *****

${OPENSHIFT_REPO_DIR}/.openshift/action_hooks
cp start start.$(date '+%Y%m%d')
cat << '__HEREDOC__' > start
#!/bin/bash

export TZ=JST-9

${OPENSHIFT_DATA_DIR}/usr/bin/apachectl -k graceful
__HEREDOC__

testrubyserver_count=$(ps aux | grep -e testrubyserver.rb | grep -e ${OPENSHIFT_APP_UUID} | grep -c -v grep)

if [ ${testrubyserver_count} -ne 0 ]; then
    kill $(ps auwx 2>/dev/null | grep -e testrubyserver.rb | grep -e ${OPENSHIFT_APP_UUID} | grep -v grep | awk '{print $2}')
fi

${OPENSHIFT_DATA_DIR}/usr/bin/apachectl -k graceful
