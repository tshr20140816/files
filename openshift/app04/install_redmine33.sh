#!/bin/bash

# rhc app create xxx ruby-2.0 mysql-5.5 cron-1.4

set -x

redmine_version=3.3.2

cd ~/app-root/repo

wget http://www.redmine.org/releases/redmine-${redmine_version}.tar.gz

tar xf redmine-${redmine_version}.tar.gz --strip-components=1
rm redmine-${redmine_version}.tar.gz

# database setting

cat << '__HEREDOC__' > config/database.yml
production:
  adapter: mysql2
  database: <%= ENV['OPENSHIFT_APP_NAME'] %>
  host: <%= ENV['OPENSHIFT_MYSQL_DB_HOST'] %>
  username: <%= ENV['OPENSHIFT_MYSQL_DB_USERNAME'] %>
  password: <%= ENV['OPENSHIFT_MYSQL_DB_PASSWORD'] %>
  port: <%= ENV['OPENSHIFT_MYSQL_DB_PORT'] %>
  encoding: utf8

development:
  adapter: sqlite3
  database: db/development.sqlite3

test:
  adapter: sqlite3
  database: db/test.sqlite3
__HEREDOC__

# gem install bundler --no-ri --no-rdoc
time gem install bundler --no-ri --no-rdoc -- --with-cflags=\"-O2 -pipe -march=native\"
# bundle install --no-color --no-deployment
time bundle install --no-color --no-deployment --without=test development --verbose --jobs=1 --retry=20

bundle exec rake generate_secret_token
RAILS_ENV=production rake db:migrate
RAILS_ENV=production REDMINE_LANG=ja bundle exec rake redmine:load_default_data

# digest auth & force https

echo user:realm:$(echo -n user:realm:${OPENSHIFT_APP_NAME} | md5sum | cut -c 1-32) > ${OPENSHIFT_DATA_DIR}/.htpasswd
echo AuthType Digest > .htaccess
echo AuthUserFile ${OPENSHIFT_DATA_DIR}/.htpasswd >> .htaccess

cat << '__HEREDOC__' >> public/.htaccess
AuthName realm

require valid-user

<Files ~ "^.(htpasswd|htaccess)$">
    deny from all
</Files>

RewriteEngine on
RewriteCond %{HTTP:X-Forwarded-Proto} !https
RewriteRule .* https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
__HEREDOC__

yes "1" | gear restart
