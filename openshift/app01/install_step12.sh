#!/bin/bash

set -x

while read LINE
do
  product=`echo $LINE | awk '{print $1}'`
  version=`echo $LINE | awk '{print $2}'`
  eval "$product"=$version
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 12 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** logrotate *****

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

mkdir ${OPENSHIFT_DATA_DIR}/logrotate
pushd ${OPENSHIFT_DATA_DIR}/logrotate > /dev/null/
cat << '__HEREDOC__' > logrotate.conf
compress
create
daily
missingok
notifempty
noolddir
rotate 7
__OPENSHIFT_DATA_DIR__redmine-__REDMINE_VERSION__/log/production.log {
daily
missingok
notifempty
copytruncate
compress
noolddir
rotate 7
}
__OPENSHIFT_LOG_DIR__cron_minutely.log {
daily
missingok
notifempty
copytruncate
compress
noolddir
rotate 7
}
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' logrotate.conf
perl -pi -e 's/__REDMINE_VERSION__/$ENV{redmine_version}/g' logrotate.conf
perl -pi -e 's/__OPENSHIFT_LOG_DIR__/$ENV{OPENSHIFT_LOG_DIR}/g' logrotate.conf
popd > /dev/null

# ***** cron *****

# *** daily ***

echo `date +%Y/%m/%d" "%H:%M:%S` cron daily >> ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/daily > /dev/null
rm -f *
touch jobs.deny

# * logrotate *

cat << '__HEREDOC__' > logrotate.sh
#!/bin/bash
/usr/bin/logrotate -v -s ${OPENSHIFT_DATA_DIR}/logrotate/logrotate.status -f ${OPENSHIFT_DATA_DIR}/logrotate/logrotate.conf
__HEREDOC__
chmod +x logrotate.sh
echo logrotate.sh >> jobs.allow
./logrotate.sh

# * mysql_backup *

cat << '__HEREDOC__' > mysql_backup.sh
#!/bin/bash
mysqldump \
--host=${OPENSHIFT_MYSQL_DB_HOST} \
--port=${OPENSHIFT_MYSQL_DB_PORT} \
--user=${OPENSHIFT_MYSQL_DB_USERNAME} \
--password=${OPENSHIFT_MYSQL_DB_PASSWORD} \
-x --all-databases --events | xz > ${OPENSHIFT_DATA_DIR}/mysql_dump_`date +%a`.xz
__HEREDOC__
chmod +x mysql_backup.sh
echo mysql_backup.sh >> jobs.allow
./mysql_backup.sh
popd > /dev/null

# *** hourly ***

echo `date +%Y/%m/%d" "%H:%M:%S` cron hourly >> ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/hourly > /dev/null
rm -f *
touch jobs.deny

# * webalizer *

cat << '__HEREDOC__' > webalizer.sh
#!/bin/bash

export TZ=JST-9
cd ${OPENSHIFT_DATA_DIR}/webalizer
./bin/webalizer -c ./etc/webalizer.conf
__HEREDOC__
chmod +x webalizer.sh
echo webalizer.sh >> jobs.allow

# * redmine repository check *

cat << '__HEREDOC__' > redmine_repository_check.sh
#!/bin/bash

if [ ! -f ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt ]; then
    touch ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt
    export TZ=JST-9
    export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
    export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
    export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
    export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
    eval "$(rbenv init -)"
    cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/redmine
    bundle exec rake redmine:fetch_changesets RAILS_ENV=production
    rm ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt
fi
__HEREDOC__
chmod +x redmine_repository_check.sh
# TODO
# echo redmine_repository_check.sh >> jobs.allow

popd > /dev/null

# *** minutely ***

echo `date +%Y/%m/%d" "%H:%M:%S` cron minutely >> ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null
rm -f *
touch jobs.deny

# * web beacon *

cat << '__HEREDOC__' > beacon.sh
#!/bin/bash

wget --spider https://tshrapp9.appspot.com/beacon.txt >/dev/null 2>&1
__HEREDOC__
chmod +x beacon.sh
echo beacon.sh >> jobs.allow

# * keep_process *

cat << '__HEREDOC__' > keep_process.sh
#!/bin/bash

# delegated
is_alive=`ps -ef | grep delegated | grep -v grep | wc -l`
if [ ${is_alive} -gt 0 ]; then
  echo delegated is alive
else
  echo RESTART delegated
  cd ${OPENSHIFT_DATA_DIR}/delegate/
  export TZ=JST-9
  ./delegated -r +=P30080
fi

# memcached
is_alive=`ps -ef | grep bin/memcached | grep -v grep | wc -l`
if [ ${is_alive} -gt 0 ]; then
  echo memcached is alive
else
  echo RESTART memcached
  cd ${OPENSHIFT_DATA_DIR}/memcached/
  ./bin/memcached -l ${OPENSHIFT_DIY_IP} -p 31211 -d
fi
__HEREDOC__
chmod +x keep_process.sh
echo keep_process.sh >> jobs.allow

# * mrtg *

cat << '__HEREDOC__' > mrtg.sh
#!/bin/bash

mpstat 5 1 | grep ^Average | awk '{print $3+$4+$5+$6+$7+$8+$9+$10}' > ${OPENSHIFT_TMP_DIR}/cpu_usage_current
cd ${OPENSHIFT_DATA_DIR}/mrtg
export TZ=JST-9
env LANG=C ./bin/mrtg mrtg.conf
__HEREDOC__
chmod +x mrtg.sh
echo mrtg.sh >> jobs.allow

# * Tiny Tiny Rss update feeds *

cat << '__HEREDOC__' > update_feeds.sh
#!/bin/bash

minute=`date +%M`

if [ `expr ${minute} % 5` -eq 0 ]; then
    ${OPENSHIFT_DATA_DIR}/php/bin/php ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss/update.php --feeds
fi
__HEREDOC__
chmod +x update_feeds.sh
echo update_feeds.sh >> jobs.allow

# * redmine repository check *

cat << '__HEREDOC__' > redmine_repository_check.sh
#!/bin/bash

minute=`date +%M`

if [ `expr ${minute} % 5` -eq 2 ]; then
    if [ ! -f ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt ]; then
        touch ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt
        export TZ=JST-9
        export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
        export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
        export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
        export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
        eval "$(rbenv init -)" 

        echo redmine_repository_check
        cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/redmine
        nohup bundle exec rake redmine:fetch_changesets RAILS_ENV=production &
        rm ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt
    fi
fi
__HEREDOC__
chmod +x redmine_repository_check.sh
echo redmine_repository_check.sh >> jobs.allow

# * passenger status *

cat << '__HEREDOC__' > passenger_status.sh
#!/bin/bash

export TZ=JST-9
cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/
echo `date +%Y/%m/%d" "%H:%M:%S` > passenger_status.txt
find ${OPENSHIFT_DATA_DIR}/.gem/gems/ -name passenger-status -type f | xargs --replace={} ruby {} --verbose >> passenger_status.txt
__HEREDOC__
chmod +x passenger_status.sh
echo passenger_status.sh >> jobs.allow

# * memcached status *

cat << '__HEREDOC__' > memcached_status.sh
#!/bin/bash

export TZ=JST-9
cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/
echo `date +%Y/%m/%d" "%H:%M:%S` > memcached_status.txt
${OPENSHIFT_DATA_DIR}/local/bin/memcached-tool ${OPENSHIFT_DIY_IP}:31211 stats >> memcached_status.txt
__HEREDOC__
chmod +x memcached_status.sh
echo memcached_status.sh >> jobs.allow

# TODO
# ${OPENSHIFT_DATA_DIR}/local/bin/memcached-tool
# ./memcached-tool ${OPENSHIFT_DIY_IP}:31211 stats
# oo-cgroup-read memory.failcnt → mrtg?

# ***** action hooks *****

pushd ${OPENSHIFT_REPO_DIR}/.openshift/action_hooks > /dev/null
cat << '__HEREDOC__' > start
export TZ=JST-9
rm ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt
${OPENSHIFT_DATA_DIR}/apache/bin/apachectl -k graceful
__HEREDOC__
popd > /dev/null

# ***** log link *****

pushd ${OPENSHIFT_LOG_DIR} > /dev/null
touch ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/log/production.log
ln -s ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/log/production.log production.log
touch ${OPENSHIFT_DATA_DIR}/apache/logs/access_log
ln -s ${OPENSHIFT_DATA_DIR}/apache/logs/access_log access_log
touch ${OPENSHIFT_DATA_DIR}/apache/logs/error_log
ln -s ${OPENSHIFT_DATA_DIR}/apache/logs/error_log error_log
popd > /dev/null

echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 12 Finish >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** start *****

# kill `netstat -anpt 2>/dev/null | grep ${OPENSHIFT_DIY_IP} | grep LISTEN | awk '{print $7}' | awk -F/ '{print $1}'`
kill `ps auwx  2>/dev/null | grep testrubyserver.rb | grep -v grep | awk '{print $2}'`
export TZ=JST-9
${OPENSHIFT_DATA_DIR}/apache/bin/apachectl -k graceful
pushd ${OPENSHIFT_DATA_DIR}/delegate
./delegated -r +=P30080
popd > /dev/null
${OPENSHIFT_DATA_DIR}/memcached/bin/memcached -l ${OPENSHIFT_DIY_IP} -p 31211 -d

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null

# * for_restart *

cat << '__HEREDOC__' > for_restart.sh

#!/bin/bash

testrubyserver_count=`ps aux | grep testrubyserver.rb | grep -v grep | wc -l`

if [ ${testrubyserver_count} -gt 0 ]; then

    # *** kill testrubyserver.rb ***
    kill `ps auwx 2>/dev/null | grep testrubyserver.rb | grep -v grep | awk '{print $2}'`

    # *** apache ***
    export TZ=JST-9
    ${OPENSHIFT_DATA_DIR}/apache/bin/apachectl -k graceful

    # *** delegate ***
    pushd ${OPENSHIFT_DATA_DIR}/delegate
    ./delegated -r +=P30080
    popd > /dev/null

    # *** memcached ***
    ${OPENSHIFT_DATA_DIR}/memcached/bin/memcached -l ${OPENSHIFT_DIY_IP} -p 31211 -d
fi
__HEREDOC__

chmod +x for_restart.sh
echo for_restart.sh >> jobs.allow

# *** webalizer first process ***

wget --spider https://${OPENSHIFT_APP_DNS}/
wget --spider https://${OPENSHIFT_APP_DNS}/redmine/
sleep 5s

${OPENSHIFT_REPO_DIR}/.openshift/cron/hourly/webalizer.sh

find ${OPENSHIFT_DATA_DIR}/.gem/gems/ -name passenger-status -type f | xargs --replace={} {} --verbose

# *** memcached information ***

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/memcached-tool ./
chmod +x memcached-tool
./memcached-tool ${OPENSHIFT_DIY_IP}:31211 dump
./memcached-tool ${OPENSHIFT_DIY_IP}:31211 stats
./memcached-tool ${OPENSHIFT_DIY_IP}:31211 display
popd > /dev/null

set +x

echo https://${OPENSHIFT_APP_DNS}/wordpress/wp-admin/install.php
# echo https://${OPENSHIFT_APP_DNS}/ttrss/install/ ttrssuser/${ttrssuser_password} ttrss ${OPENSHIFT_MYSQL_DB_HOST} admin/password
echo https://${OPENSHIFT_APP_DNS}/ttrss/
echo https://${OPENSHIFT_APP_DNS}/mail/
echo https://${OPENSHIFT_APP_DNS}/webalizer/
echo https://${OPENSHIFT_APP_DNS}/mrtg/
echo https://${OPENSHIFT_APP_DNS}/redmine/
echo https://${OPENSHIFT_APP_DNS}/info/
echo https://${OPENSHIFT_APP_DNS}/logs/
