#!/bin/bash

set -x

while read LINE
do
    product=`echo ${LINE} | awk '{print $1}'`
    version=`echo ${LINE} | awk '{print $2}'`
    eval "${product}"=${version}
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 15 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** another server list *****

env_home_backup=${HOME}
export HOME=${OPENSHIFT_DATA_DIR}
${OPENSHIFT_HOMEDIR}.gem/bin/rhc apps \
| grep uuid | grep -v ${OPENSHIFT_GEAR_DNS} \
| awk '{print $1,$3}' > ${OPENSHIFT_DATA_DIR}/another_server_list.txt
export HOME=${env_home_backup}

# ***** memory usage logging *****

cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/scripts/memory_usage_logging.sh
#!/bin/bash

export TZ=JST-9
while :
do
    dt=`date +%Y/%m/%d" "%H:%M:%S`
    usage_in_bytes=`oo-cgroup-read memory.usage_in_bytes`
    usage_in_bytes_format=`echo ${usage_in_bytes} | awk '{printf "%\047d\n", $0}'`
    failcnt=`oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $0}'`
    echo ${dt} ${usage_in_bytes_format} ${failcnt} >> ${OPENSHIFT_LOG_DIR}/memory_usage.log
    sleep 1s
done
__HEREDOC__
chmod +x ${OPENSHIFT_DATA_DIR}/scripts/memory_usage_logging.sh

# ***** redmine repository check *****

cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/scripts/redmine_repository_check.sh
#!/bin/bash

minute=`date +%M`

if [ `expr ${minute} % 5` -eq 2 ]; then
    # memory usage check
    usage_in_bytes=`oo-cgroup-read memory.usage_in_bytes`
    if [ ${usage_in_bytes} -gt 400000000 ]; then
        dt=`date +%Y/%m/%d" "%H:%M:%S`
        echo ${dt} skip ... memory use ${usage_in_bytes} bytes >> ${OPENSHIFT_LOG_DIR}\redmine_repository_check.log
        exit
    fi

    if [ -f ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt ]; then
        echo ${dt} skip ... file exists ${OPENSHIFT_TMP_DIR}redmine_repository_check.txt >> ${OPENSHIFT_LOG_DIR}\redmine_repository_check.log
        exit
    fi

    touch ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt
    export TZ=JST-9
    export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
    export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
    export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
    export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
    eval "$(rbenv init -)" 

    echo redmine_repository_check
    cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/redmine
    bundle exec rake redmine:fetch_changesets RAILS_ENV=production
    rm ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt
fi
__HEREDOC__
chmod +x ${OPENSHIFT_DATA_DIR}/scripts/redmine_repository_check.sh

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

mkdir -p ${OPENSHIFT_DATA_DIR}/logrotate
pushd ${OPENSHIFT_DATA_DIR}/logrotate > /dev/null
cat << '__HEREDOC__' > logrotate.conf
compresscmd /usr/bin/xz
uncompresscmd /usr/bin/unxz
compressext .xz

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
__OPENSHIFT_LOG_DIR__memory_usage.log {
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
perl -pi -e "s/__REDMINE_VERSION__/${redmine_version}/g" logrotate.conf
perl -pi -e 's/__OPENSHIFT_LOG_DIR__/$ENV{OPENSHIFT_LOG_DIR}/g' logrotate.conf
cat logrotate.conf
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
/usr/sbin/logrotate -v -s ${OPENSHIFT_DATA_DIR}/logrotate/logrotate.status -f ${OPENSHIFT_DATA_DIR}/logrotate/logrotate.conf
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

# * delegate *

cat << '__HEREDOC__' > delegate.sh
#!/bin/bash

export TZ=JST-9
wget --http-user=__DELEGATE_EMAL_ADDRESS__ --http-passwd=__DELEGATE_EMAIL_PASSWORD__ http://${OPENSHIFT_DIY_IP}:30080/mail/+__DELEGATE_MAIL_ALIAS__/
__HEREDOC__
delegate_mail_alias=`cat ${OPENSHIFT_DATA_DIR}/delegate_mail_alias`
perl -pi -e 's/__DELEGATE_MAIL_ALIAS__/{delegate_mail_alias}/g' delegate.sh
chmod +x delegate.sh
# TODO
# echo delegate.sh >> jobs.allow
popd > /dev/null

# *** minutely ***

echo `date +%Y/%m/%d" "%H:%M:%S` cron minutely >> ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null
rm -f *
touch jobs.deny

# * another server check *

cat << '__HEREDOC__' > another_server_check.sh
#!/bin/bash

while read LINE
do
    target_app_name=`echo $LINE | awk '{print $1}'`
    target_url=`echo $LINE | awk '{print $2}'`
    http_status=`curl -LI ${target_url} -o /dev/null -w '%{http_code}\n' -s`
    echo http_status ${http_status} ${target_url}
    if test ${http_status} -eq 503 ; then
        echo app restart ${target_url}
        env_home_backup=${HOME}
        export HOME=${OPENSHIFT_DATA_DIR}
        ${OPENSHIFT_HOMEDIR}.gem/bin/rhc app restart -a ${target_app_name}
        export HOME=${env_home_backup}
    fi
done < ${OPENSHIFT_DATA_DIR}/another_server_list.txt
__HEREDOC__
chmod +x another_server_check.sh
another_server_check=`cat ${OPENSHIFT_DATA_DIR}/another_server_check`
if [ "${another_server_check}" = "yes" ]; then
    echo another_server_check.sh >> jobs.allow
fi

# * web beacon *

cat << '__HEREDOC__' > beacon.sh
#!/bin/bash
wget --spider __WEB_BEACON_SERVER__beacon.txt?${OPENSHIFT_APP_DNS} >/dev/null 2>&1
__HEREDOC__
web_beacon_server=`cat ${OPENSHIFT_DATA_DIR}/web_beacon_server`
sed -i -e "s|__WEB_BEACON_SERVER__|${web_beacon_server}|g" beacon.sh
cat beacon.sh
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

# memory usage logging
is_alive=`ps -ef | grep memory_usage_logging.sh | grep -v grep | wc -l`
if [ ! ${is_alive} -gt 0 ]; then
    echo START memory_usage_logging.sh
    ${OPENSHIFT_DATA_DIR}/scripts/memory_usage_logging.sh >/dev/null 2>&1 &
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

cat << '__HEREDOC__' > redmine_repository_check_start.sh
#!/bin/bash

${OPENSHIFT_DATA_DIR}/scripts/redmine_repository_check.sh >/dev/null 2>&1 &
__HEREDOC__
chmod +x redmine_repository_check_start.sh
echo redmine_repository_check_start.sh >> jobs.allow

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

# * process status *

cat << '__HEREDOC__' > process_status.sh
#!/bin/bash

export TZ=JST-9
cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/
echo `date +%Y/%m/%d" "%H:%M:%S` > process_status.txt
ps auwx >> process_status.txt
__HEREDOC__
chmod +x process_status.sh
echo process_status.sh >> jobs.allow

# * cacti polling *

cat << '__HEREDOC__' > cacti_poller.sh
#!/bin/bash

minute=`date +%M`

if [ `expr ${minute} % 5` -eq 1 ]; then
    ${OPENSHIFT_DATA_DIR}/php/bin/php ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti/poller.php > /dev/null 2>&1
fi
__HEREDOC__
chmod +x cacti_poller.sh
# TODO
# echo cacti_poller.sh >> jobs.allow

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

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 15 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
