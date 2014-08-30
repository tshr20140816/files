#!/bin/bash

set -x

apache_version='2.2.27'
php_version='5.5.15'
delegate_version='9.9.11'
mrtg_version='2.17.4'
webalizer_version='2.23-08'
wordpress_version='3.9.2-ja'
ttrss_version='1.13'

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install Start >> $OPENSHIFT_LOG_DIR/install.log
echo `quota -s | grep -v a | awk {'print "Disk Usage : " $1,$4 " files"'}` >> $OPENSHIFT_LOG_DIR/install.log

# ***** apache *****

cd $OPENSHIFT_TMP_DIR
if [ -d $OPENSHIFT_DATA_DIR/apache ]
then

echo `date +%Y/%m/%d" "%H:%M:%S` httpd skip all >> $OPENSHIFT_LOG_DIR/install.log

else

echo `date +%Y/%m/%d" "%H:%M:%S` httpd wget >> $OPENSHIFT_LOG_DIR/install.log
wget http://ftp.riken.jp/net/apache//httpd/httpd-${apache_version}.tar.gz
echo `date +%Y/%m/%d" "%H:%M:%S` httpd tar >> $OPENSHIFT_LOG_DIR/install.log
tar xfz httpd-${apache_version}.tar.gz
cd httpd-${apache_version}
echo `date +%Y/%m/%d" "%H:%M:%S` httpd configure >> $OPENSHIFT_LOG_DIR/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure --prefix=$OPENSHIFT_DATA_DIR/apache \
--enable-mods-shared='all proxy' 2>&1 | tee $OPENSHIFT_LOG_DIR/httpd.configure.log
echo `date +%Y/%m/%d" "%H:%M:%S` httpd make >> $OPENSHIFT_LOG_DIR/install.log
time make -j2
echo `date +%Y/%m/%d" "%H:%M:%S` httpd make install >> $OPENSHIFT_LOG_DIR/install.log
make install
echo `date +%Y/%m/%d" "%H:%M:%S` httpd conf >> $OPENSHIFT_LOG_DIR/install.log
cd $OPENSHIFT_DATA_DIR/apache
cp conf/httpd.conf conf/httpd.conf.`date '+%Y%m%d'`
perl -pi -e 's/^Listen .+$/Listen $ENV{OPENSHIFT_DIY_IP}:8080/g' conf/httpd.conf
cat << '__HEREDOC__' >> conf/httpd.conf

Include conf/custom.conf
__HEREDOC__
perl -pi -e 's/(^ +DirectoryIndex .*$)/$1 index.php/g' conf/httpd.conf

cat << '__HEREDOC__' >> conf/custom.conf
MinSpareServers 1
MaxSpareServers 5
StartServers 1

ServerTokens Prod

# for delegate
ProxyRequests Off
ProxyPass /mail/ http://__OPENSHIFT_DIY_IP__:50080/mail/
ProxyPassReverse /mail/ http://__OPENSHIFT_DIY_IP__:50080/mail/
ProxyMaxForwards 10

AddType application/x-httpd-php .php

<FilesMatch ".php$">
    SetHandler application/x-httpd-php
</FilesMatch>

# AddOutputFilterByType DEFLATE text/html text/plain text/xml 

Header unset x-powered-by
Header set server Apache
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' conf/custom.conf

cat << '__HEREDOC__' > htdocs/robots.txt
User-agent: *
Disallow: /
__HEREDOC__

cd $OPENSHIFT_TMP_DIR
rm httpd-${apache_version}.tar.gz
rm -rf httpd-${apache_version}

fi

# ***** php *****

echo `quota -s | grep -v a | awk {'print "Disk Usage : " $1,$4 " files"'}` >> $OPENSHIFT_LOG_DIR/install.log
cd $OPENSHIFT_TMP_DIR
echo `date +%Y/%m/%d" "%H:%M:%S` php wget >> $OPENSHIFT_LOG_DIR/install.log
wget http://jp1.php.net/get/php-${php_version}.tar.gz/from/this/mirror -O php-${php_version}.tar.gz
echo `date +%Y/%m/%d" "%H:%M:%S` php tar >> $OPENSHIFT_LOG_DIR/install.log
tar xfz php-${php_version}.tar.gz
cd php-${php_version}
echo `date +%Y/%m/%d" "%H:%M:%S` php configure >> $OPENSHIFT_LOG_DIR/install.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=$OPENSHIFT_DATA_DIR/php \
--with-apxs2=$OPENSHIFT_DATA_DIR/apache/bin/apxs \
--with-mysql \
--with-pdo-mysql \
--with-curl \
--with-libdir=lib64 \
--with-bz2 \
--with-iconv \
--with-openssl \
--with-zlib \
--enable-exif \
--enable-ftp \
--enable-xml \
--enable-mbstring \
--enable-mbregex \
--enable-sockets \
--with-gettext=$OPENSHIFT_DATA_DIR/php 2>&1 | tee $OPENSHIFT_LOG_DIR/php.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` php make >> $OPENSHIFT_LOG_DIR/install.log
time make
echo `date +%Y/%m/%d" "%H:%M:%S` php make install >> $OPENSHIFT_LOG_DIR/install.log
make install
echo `date +%Y/%m/%d" "%H:%M:%S` php make conf >> $OPENSHIFT_LOG_DIR/install.log
cp php.ini-production $OPENSHIFT_DATA_DIR/php/lib/php.ini
cp php.ini-production $OPENSHIFT_DATA_DIR/php/lib/php.ini-production
cp php.ini-development $OPENSHIFT_DATA_DIR/php/lib/php.ini-development
cd $OPENSHIFT_DATA_DIR/php
perl -pi -e 's/^short_open_tag .+$/short_open_tag = On/g' lib/php.ini
perl -pi -e 's/(^;date.timezone =.*$)/$1\r\ndate.timezone = Asia\/Tokyo/g' lib/php.ini

cd $OPENSHIFT_TMP_DIR
rm php-${php_version}.tar.gz
rm -rf php-${php_version}

# ***** delegate *****

echo `quota -s | grep -v a | awk {'print "Disk Usage : " $1,$4 " files"'}` >> $OPENSHIFT_LOG_DIR/install.log
cd $OPENSHIFT_TMP_DIR
echo `date +%Y/%m/%d" "%H:%M:%S` delegate wget >> $OPENSHIFT_LOG_DIR/install.log
wget http://www.delegate.org/anonftp/DeleGate/delegate${delegate_version}.tar.gz
echo `date +%Y/%m/%d" "%H:%M:%S` delegate tar >> $OPENSHIFT_LOG_DIR/install.log
tar xfz delegate${delegate_version}.tar.gz
cd delegate${delegate_version}
echo `date +%Y/%m/%d" "%H:%M:%S` delegate make >> $OPENSHIFT_LOG_DIR/install.log
perl -pi -e 's/^ADMIN = undef$/ADMIN = admin\@rhcloud.local/g' src/Makefile
time make -j2 CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" 
mkdir $OPENSHIFT_DATA_DIR/delegate/
cp src/delegated $OPENSHIFT_DATA_DIR/delegate/

# apache htdocs
mkdir $OPENSHIFT_DATA_DIR/apache/htdocs/delegate/icons
cp src/builtin/icons/ysato/*.* $OPENSHIFT_DATA_DIR/apache/htdocs/delegate/icons/
# */

cd $OPENSHIFT_DATA_DIR/delegate/
cat << '__HEREDOC__' > P50080
-P__OPENSHIFT_DIY_IP__:50080
SERVER=http
ADMIN=admin@rhcloud.local
DGROOT=__OPENSHIFT_DATA_DIR__delegate
MOUNT="/mail/* pop://pop.mail.yahoo.co.jp:110/* noapop" 
FTOCL="/bin/sed -f __OPENSHIFT_DATA_DIR__delegate/filter.txt" 
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' P50080
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' P50080
cat << '__HEREDOC__' > filter.txt
s/http:..__OPENSHIFT_DIY_IP__:50080.-.builtin.icons.ysato/\/delegate\/icons/g
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' filter.txt

cd $OPENSHIFT_TMP_DIR
rm delegate${delegate_version}.tar.gz
rm -rf delegate${delegate_version}

# ***** mrtg *****

echo `quota -s | grep -v a | awk {'print "Disk Usage : " $1,$4 " files"'}` >> $OPENSHIFT_LOG_DIR/install.log
cd $OPENSHIFT_TMP_DIR
echo `date +%Y/%m/%d" "%H:%M:%S` mrtg wget >> $OPENSHIFT_LOG_DIR/install.log
wget http://oss.oetiker.ch/mrtg/pub/mrtg-${mrtg_version}.tar.gz
echo `date +%Y/%m/%d" "%H:%M:%S` mrtg tar >> $OPENSHIFT_LOG_DIR/install.log
tar xfz mrtg-${mrtg_version}.tar.gz
cd mrtg-${mrtg_version}
echo `date +%Y/%m/%d" "%H:%M:%S` mrtg configure >> $OPENSHIFT_LOG_DIR/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure --prefix=$OPENSHIFT_DATA_DIR/mrtg 2>&1 | tee $OPENSHIFT_LOG_DIR/mrtg.configure.log
echo `date +%Y/%m/%d" "%H:%M:%S` mrtg make >> $OPENSHIFT_LOG_DIR/install.log
time make
echo `date +%Y/%m/%d" "%H:%M:%S` mrtg make install >> $OPENSHIFT_LOG_DIR/install.log
make install
mkdir $OPENSHIFT_DATA_DIR/mrtg/workdir
mkdir $OPENSHIFT_DATA_DIR/mrtg/scripts
cd $OPENSHIFT_DATA_DIR/mrtg

touch scripts/cpu_usage.sh
cat << '__HEREDOC__' > scripts/cpu_usage.sh
#!/bin/bash

echo `cat $OPENSHIFT_TMP_DIR/cpu_usage_current`
echo 0
echo dummy
echo cpu usage
__HEREDOC__
chmod +x scripts/cpu_usage.sh

touch scripts/disk_usage.sh
cat << '__HEREDOC__' > scripts/disk_usage.sh
#!/bin/bash

echo `quota | grep -v a | awk '{print $1}'`
echo `quota | grep -v a | awk '{print $3}'`
echo dummy
echo disk usage
__HEREDOC__
chmod +x scripts/disk_usage.sh

touch scripts/file_usage.sh
cat << '__HEREDOC__' > scripts/file_usage.sh
#!/bin/bash

echo `quota | grep -v a | awk '{print $4}'`
echo `quota | grep -v a | awk '{print $6}'`
echo dummy
echo file usage
__HEREDOC__
chmod +x scripts/file_usage.sh

touch scripts/memory_usage.sh
cat << '__HEREDOC__' > scripts/memory_usage.sh
#!/bin/bash

echo `oo-cgroup-read memory.usage_in_bytes | awk '{print $1}'`
echo `oo-cgroup-read memory.limit_in_bytes | awk '{print $1}'`
echo dummy
echo memory usage
__HEREDOC__
chmod +x scripts/memory_usage.sh

cat << '__HEREDOC__' > mrtg.conf
WorkDir: __OPENSHIFT_DATA_DIR__apache/htdocs/mrtg/
HtmlDir: __OPENSHIFT_DATA_DIR__apache/htdocs/mrtg/
ImageDir: __OPENSHIFT_DATA_DIR__apache/htdocs/mrtg/
LogDir: __OPENSHIFT_DATA_DIR__mrtg/log/
Refresh: 60000

PageTop[_]: <H1>MRTG</H1>

Target[disk]: `$OPENSHIFT_DATA_DIR/mrtg/scripts/disk_usage.sh`
Title[disk]: Disk
Options[disk]: gauge, nobanner, growright, unknaszero, noinfo
AbsMax[disk]: 10000000
MaxBytes[disk]: 1048576
kilo[disk]: 1024
YLegend[disk]: Disk Use
LegendI[disk]: Use
LegendO[disk]: Limit
Legend1[disk]: Disk Use
Legend2[disk]: Disk Limit
ShortLegend[disk]: B
Suppress[disk]: y
Factor[disk]: 1024
YTicsFactor[disk]: 1024

Target[file]: `$OPENSHIFT_DATA_DIR/mrtg/scripts/file_usage.sh`
Title[file]: Files
Options[file]: gauge, nobanner, growright, unknaszero, noinfo, integer
AbsMax[file]: 1000000
MaxBytes[file]: 80000
YLegend[file]: File Count
LegendI[file]: Files
LegendO[file]: Limit
Legend1[file]: File Count
Legend2[file]: File Count Limit
ShortLegend[file]: files
Suppress[file]: y

Target[memory]: `$OPENSHIFT_DATA_DIR/mrtg/scripts/memory_usage.sh`
Title[memory]: Memory
Options[memory]: gauge, nobanner, growright, unknaszero, noinfo
AbsMax[memory]: 5368709120
MaxBytes[memory]: 536870912
YLegend[memory]: Memory Use
LegendI[memory]: Use
LegendO[memory]: Limit
Legend1[memory]: Memory Use
Legend2[memory]: Memory Limit
ShortLegend[memory]: B
Suppress[memory]: y

Target[cpu]: `$OPENSHIFT_DATA_DIR/mrtg/scripts/cpu_usage.sh`
Title[cpu]: Cpu
Options[cpu]: gauge, nobanner, growright, unknaszero, noinfo, noo
AbsMax[cpu]: 200
MaxBytes[cpu]: 100
YLegend[cpu]: Cpu Usage
LegendI[cpu]: Usage
Legend1[cpu]: Cpu Usage
ShortLegend[cpu]: %
Suppress[cpu]: y
WithPeak[cpu]: dwm
Unscaled[cpu]: dwm
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' mrtg.conf

mkdir $OPENSHIFT_DATA_DIR/mrtg/log
mkdir $OPENSHIFT_DATA_DIR/apache/htdocs/mrtg
cd $OPENSHIFT_DATA_DIR/mrtg
./bin/indexmaker --output=index.html mrtg.conf
cp index.html ../apache/htdocs/mrtg/

cd $OPENSHIFT_TMP_DIR
rm mrtg-${mrtg_version}.tar.gz
rm -rf mrtg-${mrtg_version}

# ***** webalizer *****

echo `quota -s | grep -v a | awk {'print "Disk Usage : " $1,$4 " files"'}` >> $OPENSHIFT_LOG_DIR/install.log
cd $OPENSHIFT_TMP_DIR
echo `date +%Y/%m/%d" "%H:%M:%S` webalizer wget >> $OPENSHIFT_LOG_DIR/install.log
wget ftp://ftp.mrunix.net/pub/webalizer/webalizer-${webalizer_version}-src.tgz
echo `date +%Y/%m/%d" "%H:%M:%S` webalizer tar >> $OPENSHIFT_LOG_DIR/install.log
tar xfz webalizer-${webalizer_version}-src.tgz
cd webalizer-${webalizer_version}
mv lang/webalizer_lang.japanese lang/webalizer_lang.japanese_euc
iconv -f euc-jp -t utf-8 lang/webalizer_lang.japanese_euc > lang/webalizer_lang.japanese
echo `date +%Y/%m/%d" "%H:%M:%S` webalizer configure >> $OPENSHIFT_LOG_DIR/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--prefix=$OPENSHIFT_DATA_DIR/webalizer \
--mandir=$OPENSHIFT_DATA_DIR/webalizer \
--with-language=japanese --enable-dns 2>&1 | tee $OPENSHIFT_LOG_DIR/webalizer.configure.log
echo `date +%Y/%m/%d" "%H:%M:%S` webalizer make >> $OPENSHIFT_LOG_DIR/install.log
time make
echo `date +%Y/%m/%d" "%H:%M:%S` webalizer make install >> $OPENSHIFT_LOG_DIR/install.log
make install

# apache htdocs
mkdir $OPENSHIFT_DATA_DIR/apache/htdocs/usage
cd $OPENSHIFT_DATA_DIR/webalizer/etc
cp webalizer.conf.sample webalizer.conf
echo >> webalizer.conf
echo >> webalizer.conf
echo LogFile $OPENSHIFT_DATA_DIR/apache/logs/access_log >> webalizer.conf
echo OutputDir $OPENSHIFT_DATA_DIR/apache/htdocs/usage >> webalizer.conf
echo HostName $OPENSHIFT_APP_DNS >> webalizer.conf
echo UseHTTPS yes >> webalizer.conf

cd $OPENSHIFT_TMP_DIR
rm webalizer-${webalizer_version}-src.tgz
rm -rf webalizer-${webalizer_version}

# ***** wordpress *****

echo `quota -s | grep -v a | awk {'print "Disk Usage : " $1,$4 " files"'}` >> $OPENSHIFT_LOG_DIR/install.log
mkdir $OPENSHIFT_DATA_DIR/apache/htdocs/wordpress
cd $OPENSHIFT_DATA_DIR/apache/htdocs/wordpress
echo `date +%Y/%m/%d" "%H:%M:%S` wordpress wget >> $OPENSHIFT_LOG_DIR/install.log
wget http://ja.wordpress.org/wordpress-${wordpress_version}.tar.gz
echo `date +%Y/%m/%d" "%H:%M:%S` wordpress tar >> $OPENSHIFT_LOG_DIR/install.log
tar xfz wordpress-${wordpress_version}.tar.gz --strip-components=1

# force ssl patch
mkdir wp-content/mu-plugins
cd wp-content/mu-plugins
wget https://gist.githubusercontent.com/franz-josef-kaiser/1891564/raw/9d3f519c1cfb0fff9ad5ca31f3e783deaf5d561c/is_ssl.php
cd ../../wp-includes
perl -pi -e 's/(^function is_ssl\(\) \{)$/$1\n\treturn is_maybe_ssl\(\);/g' functions.php

# create database
wpuser_password=`uuidgen | awk -F - '{print $1 $2 $3 $4 $5}' | head -c 20`
cd $OPENSHIFT_TMP_DIR
cat << '__HEREDOC__' > create_database_wordpress.txt
CREATE DATABASE wordpress CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON wordpress.* TO wpuser@__OPENSHIFT_MYSQL_DB_HOST__ IDENTIFIED BY '__PASSWORD__';
FLUSH PRIVILEGES;
EXIT
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' create_database_wordpress.txt
sed -i -e "s/__PASSWORD__/$wpuser_password/g" create_database_wordpress.txt

mysql -u "$OPENSHIFT_MYSQL_DB_USERNAME" \
--password="$OPENSHIFT_MYSQL_DB_PASSWORD" \
-h "$OPENSHIFT_MYSQL_DB_HOST" \
-P "$OPENSHIFT_MYSQL_DB_PORT" < create_database_wordpress.txt

cd $OPENSHIFT_DATA_DIR/apache/htdocs/wordpress
cat << '__HEREDOC__' > wp-config.php
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wpuser');
define('DB_PASSWORD', '__PASSWORD__');
define('DB_HOST', '__OPENSHIFT_MYSQL_DB_HOST__');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', 'utf8_general_ci');
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' wp-config.php
sed -i -e "s/__PASSWORD__/$wpuser_password/g" wp-config.php
curl -o $OPENSHIFT_TMP_DIR/salt.txt https://api.wordpress.org/secret-key/1.1/salt/
cat $OPENSHIFT_TMP_DIR/salt.txt >> wp-config.php
rm $OPENSHIFT_TMP_DIR/salt.txt
cat << '__HEREDOC__' >> wp-config.php

$table_prefix  = 'wp_';
define('WPLANG', 'ja');
define('WP_DEBUG', false);

define('FORCE_SSL_ADMIN', true);
define('FORCE_SSL_LOGIN', true);

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');

__HEREDOC__

echo `date +%Y/%m/%d" "%H:%M:%S` wordpress mysql wpuser/$wpuser_password >> $OPENSHIFT_LOG_DIR/install.log

cd $OPENSHIFT_DATA_DIR/apache/htdocs/wordpress
rm wordpress-${wordpress_version}.tar.gz

# ***** tiny tiny rss *****

echo `quota -s | grep -v a | awk {'print "Disk Usage : " $1,$4 " files"'}` >> $OPENSHIFT_LOG_DIR/install.log
mkdir $OPENSHIFT_DATA_DIR/apache/htdocs/ttrss
cd $OPENSHIFT_DATA_DIR/apache/htdocs/ttrss
echo `date +%Y/%m/%d" "%H:%M:%S` ttrss wget >> $OPENSHIFT_LOG_DIR/install.log
wget https://github.com/gothfox/Tiny-Tiny-RSS/archive/${ttrss_version}.tar.gz
echo `date +%Y/%m/%d" "%H:%M:%S` ttrss tar >> $OPENSHIFT_LOG_DIR/install.log
tar xfz ${ttrss_version}.tar.gz --strip-components=1

# create database
ttrssuser_password=`uuidgen | awk -F - '{print $1 $2 $3 $4 $5}' | head -c 20`
cd $OPENSHIFT_TMP_DIR
cat << '__HEREDOC__' > create_database_ttrss.txt
CREATE DATABASE ttrss CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON ttrss.* TO ttrssuser@__OPENSHIFT_MYSQL_DB_HOST__ IDENTIFIED BY '__PASSWORD__';
FLUSH PRIVILEGES;
EXIT
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' create_database_ttrss.txt
# perl -pi -e 's/__PASSWORD__/$ttrssuser_password/g' create_database_ttrss.txt
sed -i -e "s/__PASSWORD__/$ttrssuser_password/g" create_database_ttrss.txt

mysql -u "$OPENSHIFT_MYSQL_DB_USERNAME" \
--password="$OPENSHIFT_MYSQL_DB_PASSWORD" \
-h "$OPENSHIFT_MYSQL_DB_HOST" \
-P "$OPENSHIFT_MYSQL_DB_PORT" < create_database_ttrss.txt

mysql -u "$OPENSHIFT_MYSQL_DB_USERNAME" \
--password="$OPENSHIFT_MYSQL_DB_PASSWORD" \
-h "$OPENSHIFT_MYSQL_DB_HOST" \
-P "$OPENSHIFT_MYSQL_DB_PORT" ttrss < $OPENSHIFT_DATA_DIR/apache/htdocs/ttrss/schema/ttrss_schema_mysql.sql

echo `date +%Y/%m/%d" "%H:%M:%S` ttrss mysql ttrssuser/$ttrssuser_password >> $OPENSHIFT_LOG_DIR/install.log

cd $OPENSHIFT_DATA_DIR/apache/htdocs/ttrss
rm ${ttrss_version}.tar.gz

# ***** PHP iCalendar *****

echo `quota -s | grep -v a | awk {'print "Disk Usage : " $1,$4 " files"'}` >> $OPENSHIFT_LOG_DIR/install.log
mkdir $OPENSHIFT_DATA_DIR/apache/htdocs/cal
cd $OPENSHIFT_DATA_DIR/apache/htdocs/cal
echo `date +%Y/%m/%d" "%H:%M:%S` iCalendar wget >> $OPENSHIFT_LOG_DIR/install.log
wget http://downloads.sourceforge.net/project/phpicalendar/phpicalendar/phpicalendar%202.4%20RC7/phpicalendar-2.4_20100615.tar.bz2
echo `date +%Y/%m/%d" "%H:%M:%S` iCalendar tar >> $OPENSHIFT_LOG_DIR/install.log
tar jxf phpicalendar-2.4_20100615.tar.bz2 --strip-components=1

cd functions
wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/icalendar/ical_parser.php.patch
patch ical_parser.php ical_parser.php.patch

cd $OPENSHIFT_DATA_DIR/apache/htdocs/cal
rm phpicalendar-2.4_20100615.tar.bz2

# ***** cron *****

# *** daily ***

echo `date +%Y/%m/%d" "%H:%M:%S` cron daily >> $OPENSHIFT_LOG_DIR/install.log
pushd $OPENSHIFT_REPO_DIR/.openshift/cron/daily > /dev/null
touch jobs.deny

# * mysql_backup *

wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/redmine/mysql_backup.sh
chmod +x mysql_backup.sh
echo mysql_backup.sh >> jobs.allow
./mysql_backup.sh
popd > /dev/null

# *** hourly ***

echo `date +%Y/%m/%d" "%H:%M:%S` cron hourly >> $OPENSHIFT_LOG_DIR/install.log
pushd $OPENSHIFT_REPO_DIR/.openshift/cron/hourly > /dev/null
touch jobs.deny

# * webalizer *

cat << '__HEREDOC__' > webalizer.sh
#!/bin/bash

export TZ=JST-9
cd $OPENSHIFT_DATA_DIR/webalizer
./bin/webalizer -c ./etc/webalizer.conf
__HEREDOC__
chmod +x webalizer.sh
echo webalizer.sh >> jobs.allow
popd > /dev/null

# *** minutely ***

echo `date +%Y/%m/%d" "%H:%M:%S` cron minutely >> $OPENSHIFT_LOG_DIR/install.log
pushd $OPENSHIFT_REPO_DIR/.openshift/cron/minutely > /dev/null
touch jobs.deny

# * keep_delegated *

cat << '__HEREDOC__' > keep_delegated.sh
#!/bin/bash

is_alive=`ps -ef | grep delegated | grep -v grep  | grep -v keep_delegate | wc -l`
if [ $is_alive -eq 1 ]; then
  echo delegated is alive
else
  echo $is_alive
  echo RESTART delegated
  cd $OPENSHIFT_DATA_DIR/delegate/
  export TZ=JST-9
  ./delegated -r +=P50080
fi
__HEREDOC__
chmod +x keep_delegated.sh
echo keep_delegated.sh >> jobs.allow

# * mrtg *

cat << '__HEREDOC__' > mrtg.sh
#!/bin/bash

mpstat 5 1 | grep ^Average | awk '{print $3}' > $OPENSHIFT_TMP_DIR/cpu_usage_current
cd $OPENSHIFT_DATA_DIR/mrtg
export TZ=JST-9
env LANG=C ./bin/mrtg mrtg.conf
__HEREDOC__
chmod +x mrtg.sh
echo mrtg.sh >> jobs.allow

# * tiny tiny rss *

cat << '__HEREDOC__' > update_feeds.sh
#!/bin/bash
$OPENSHIFT_DATA_DIR/apache/htdocs/ttrss/update.php --feeds
__HEREDOC__
chmod +x update_feeds.sh
# echo update_feeds.sh >> jobs.allow

echo `quota -s | grep -v a | awk {'print "Disk Usage : " $1,$4 " files"'}` >> $OPENSHIFT_LOG_DIR/install.log
echo `date +%Y/%m/%d" "%H:%M:%S` Install Finish >> $OPENSHIFT_LOG_DIR/install.log

# ***** start *****

kill `netstat -anpt 2>/dev/null | grep $OPENSHIFT_DIY_IP | grep LISTEN | awk '{print $7}' | awk -F/ '{print $1}'`
cd $OPENSHIFT_DATA_DIR
export TZ=JST-9
./apache/bin/apachectl -k graceful
cd delegate
./delegated -r +=P50080

wget --spider https://$OPENSHIFT_APP_DNS/
sleep 5s

cd $OPENSHIFT_REPO_DIR/.openshift/cron/hourly/
./webalizer.sh

set +x

echo https://$OPENSHIFT_APP_DNS/wordpress/wp-admin/install.php
echo https://$OPENSHIFT_APP_DNS/ttrss/install/ ttrssuser/$ttrssuser_password ttrss $OPENSHIFT_MYSQL_DB_HOST admin/password
echo https://$OPENSHIFT_APP_DNS/cal/
echo https://$OPENSHIFT_APP_DNS/mail/
echo https://$OPENSHIFT_APP_DNS/usage/
echo https://$OPENSHIFT_APP_DNS/mrtg/

