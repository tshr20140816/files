#!/bin/bash

# rhc app create xxx php-5.4 mysql-5.5 cron-1.4 phpmyadmin-4

set -x

wordpress_version=4.7.3-ja

cd ~/app-root/repo

wget https://ja.wordpress.org/wordpress-${wordpress_version}.tar.gz
tar xf wordpress-${wordpress_version}.tar.gz --strip-components=1
rm wordpress-${wordpress_version}.tar.gz

# *** create database ***

cd /tmp

cat << '__HEREDOC__' > create_database_wordpress.txt
DROP DATABASE IF EXISTS wordpress;
CREATE DATABASE wordpress CHARACTER SET utf8 COLLATE utf8_general_ci;
__HEREDOC__

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" < create_database_wordpress.txt

rm create_database_wordpress.txt

# *** database setting ***

cd ~/app-root/repo

cat << '__HEREDOC__' > wp-config.php
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', getenv('OPENSHIFT_MYSQL_DB_USERNAME'));
define('DB_PASSWORD', getenv('OPENSHIFT_MYSQL_DB_PASSWORD'));
define('DB_HOST', getenv('OPENSHIFT_MYSQL_DB_HOST') . ':' . getenv('OPENSHIFT_MYSQL_DB_PORT'));
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', 'utf8_general_ci');
__HEREDOC__

curl -o ./salt.txt https://api.wordpress.org/secret-key/1.1/salt/
cat ./salt.txt >> wp-config.php
rm ./salt.txt
cat << '__HEREDOC__' >> wp-config.php

$table_prefix  = 'wp_';
define('WPLANG', 'ja');

define('WP_DEBUG', false);
ini_set('display_errors', 0);
ini_set("log_errors", 1);
ini_set("error_log", getenv('OPENSHIFT_LOG_DIR') . "wordpress_error.log");

// http://codex.wordpress.org/Administration_Over_SSL
define('FORCE_SSL_ADMIN', true);
if ($_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')
    $_SERVER['HTTPS']='on';

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');

__HEREDOC__

# *** digest auth & force https ***

echo user:realm:$(echo -n user:realm:${OPENSHIFT_APP_NAME} | md5sum | cut -c 1-32) > ${OPENSHIFT_DATA_DIR}/.htpasswd
echo AuthType Digest > ./.htaccess
echo AuthUserFile ${OPENSHIFT_DATA_DIR}/.htpasswd >> ./.htaccess

cat << '__HEREDOC__' >> ./.htaccess
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
