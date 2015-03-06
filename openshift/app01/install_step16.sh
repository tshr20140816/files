#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

pushd ${OPENSHIFT_DATA_DIR}/scripts > /dev/null

# ***** logrotate (zantei) *****
# https://bugzilla.redhat.com/show_bug.cgi?id=1181059

cat << '__HEREDOC__' > logrotate_zantei.sh
#!/bin/bash
export TZ=JST-9

day='00'
while :
do
    sleep 10m
    if [ %{day} != $(date +%d) ]; then
        day=$(date +%d)
        echo $(date +%Y/%m/%d" "%H:%M:%S) >> ${OPENSHIFT_LOG_DIR}/logrotate_zantei.log
        /usr/sbin/logrotate -v \
            -s ${OPENSHIFT_DATA_DIR}/logrotate/logrotate.status \
            -f ${OPENSHIFT_DATA_DIR}/logrotate/logrotate.conf \
            >> ${OPENSHIFT_LOG_DIR}/logrotate_zantei.log
    fi
done
__HEREDOC__
chmod +x logrotate_zantei.sh

# ***** memory usage logging *****

cat << '__HEREDOC__' > memory_usage_logging.sh
#!/bin/bash

export TZ=JST-9
while :
do
    dt=$(date +%Y/%m/%d" "%H:%M:%S)
    usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
    usage_in_bytes_format=$(echo ${usage_in_bytes} | awk '{printf "%\047d\n", $0}')
    failcnt=$(oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $0}')
    echo ${dt} ${usage_in_bytes_format} ${failcnt} >> ${OPENSHIFT_LOG_DIR}/memory_usage.log
    tail -n 100 ${OPENSHIFT_LOG_DIR}/memory_usage.log | sort -r > ${OPENSHIFT_LOG_DIR}/memory_usage_tail_100_sort_r.log
    for size in 300 350 400 450 500
    do
        filename=${OPENSHIFT_TMP_DIR}/memory_over_${size}M
        [ ${usage_in_bytes} -gt $((${size} * (10**6))) ] && touch ${filename} || rm -f ${filename}
    done
    [ -f ${OPENSHIFT_TMP_DIR}/stop ] && exit || sleep 1s
done
__HEREDOC__
chmod +x memory_usage_logging.sh

# ***** cron scripts *****

# *** logrotate ***

cat << '__HEREDOC__' > logrotate.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S)

cd ${OPENSHIFT_DATA_DIR}/logrotate
logrotate logrotate.conf -s logrotate.status
__HEREDOC__
chmod +x logrotate.sh

# *** redmine repository check ***

cat << '__HEREDOC__' > redmine_repository_check.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S)
minute=$(date +%M)
dt=$(date +%Y/%m/%d" "%H:%M:%S)

if [ $(expr ${minute} % 5) -eq 2 ]; then
    echo ${dt} start >> ${OPENSHIFT_LOG_DIR}/redmine_repository_check.log

    # memory usage check
    usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
    if [ ${usage_in_bytes} -gt 400000000 ]; then
        dt=$(date +%Y/%m/%d" "%H:%M:%S)
        echo ${dt} skip ... memory use ${usage_in_bytes} bytes \
        >> ${OPENSHIFT_LOG_DIR}/redmine_repository_check.log
        exit
    fi

    if [ -f ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt ]; then
        dt=$(date +%Y/%m/%d" "%H:%M:%S)
        echo ${dt} skip ... file exists ${OPENSHIFT_TMP_DIR}redmine_repository_check.txt \
        >> ${OPENSHIFT_LOG_DIR}/redmine_repository_check.log
        exit
    fi

    touch ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt
    export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
    export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
    export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
    export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
    eval "$(rbenv init -)" 

    echo redmine_repository_check
    cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/redmine
    bundle exec rake redmine:fetch_changesets RAILS_ENV=production
    rm ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt
    echo $(date +%Y/%m/%d" "%H:%M:%S) finish ${dt} \
    >> ${OPENSHIFT_LOG_DIR}/redmine_repository_check.log
fi
__HEREDOC__
chmod +x redmine_repository_check.sh

# *** my server check ***

cat << '__HEREDOC__' > my_server_check.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S)

target_url="https://${OPENSHIFT_APP_DNS}/?server=${OPENSHIFT_APP_DNS}"
http_status=$(curl -LI ${target_url} -o /dev/null -w '%{http_code}\n' -s)
echo http_status ${http_status} ${target_url}
if [ ${http_status} -eq 503 ]; then
    dt=$(date +%Y%m%d%H)
    # TODO
    # curl -F "subject=${OPENSHIFT_APP_DNS} RESTART" -F "body=${OPENSHIFT_APP_DNS} RESTART" --digest -u username:${dt} https://xxx/sendadminmail
    echo auto restart ${OPENSHIFT_APP_DNS}
    /usr/bin/gear stop
    /usr/bin/gear start
    echo $(date +%Y/%m/%d" "%H:%M:%S) Auto Restart >> ${OPENSHIFT_LOG_DIR}/auto_restart.log
fi
__HEREDOC__
chmod +x my_server_check.sh

# *** another server check ***

cat << '__HEREDOC__' > another_server_check.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S)

another_server_check=$(cat ${OPENSHIFT_DATA_DIR}/params/another_server_check)
if [ "${another_server_check}" != "yes" ]; then
    exit
fi

while read LINE
do
    target_app_name=$(echo $LINE | awk '{print $1}')
    target_url=$(echo $LINE | awk '{print $2}')
    http_status=$(curl -LI ${target_url}?server=${OPENSHIFT_APP_DNS} -o /dev/null -w '%{http_code}\n' -s)
    echo http_status ${http_status} ${target_url}
    if [ ${http_status} -eq 503 ]; then
        echo app restart ${target_url}
        curl --digest -u $(cat ${OPENSHIFT_DATA_DIR}/web_beacon_server_user):$(date +%Y%m%d%H) \
         -F "subject=SERVER RESTART" \
         -F "body=${target_app_name} FROM ${OPENSHIFT_GEAR_DNS}" \
         $(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)sendadminmail

        export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
        export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
        export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
        export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
        eval "$(rbenv init -)"

        env_home_backup=${HOME}
        export HOME=${OPENSHIFT_DATA_DIR}
        ${OPENSHIFT_DATA_DIR}.gem/bin/rhc app restart -a ${target_app_name}
        export HOME=${env_home_backup}
    fi
done < ${OPENSHIFT_DATA_DIR}/another_server_list.txt
__HEREDOC__
chmod +x another_server_check.sh

# *** web beacon ***

cat << '__HEREDOC__' > beacon.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S)

curl -LI __WEB_BEACON_SERVER__beacon.txt?${OPENSHIFT_APP_DNS} -s | head -n1
__HEREDOC__
web_beacon_server=$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)
sed -i -e "s|__WEB_BEACON_SERVER__|${web_beacon_server}|g" beacon.sh
cat beacon.sh
chmod +x beacon.sh

# *** keep_process ***

cat << '__HEREDOC__' > keep_process.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S)

# memcached
is_alive=$(ps awhx | grep bin/memcached | grep -v grep | grep ${OPENSHIFT_DIY_IP} | wc -l)
if [ ${is_alive} -gt 0 ]; then
    if [ -f ${OPENSHIFT_TMP_DIR}/stop ]; then
        kill $(ps awhx | grep bin/memcached | grep -v grep | grep ${OPENSHIFT_DIY_IP} | awk '{print $2}' | head -n1)
    else
        echo memcached is alive
    fi
elif [ ! -f ${OPENSHIFT_TMP_DIR}/stop ]; then
    echo RESTART memcached
    cd ${OPENSHIFT_DATA_DIR}/memcached/
    ./bin/memcached -l ${OPENSHIFT_DIY_IP} -p 31211 -d
fi

# delegated
is_alive=$(ps awhx | grep delegated | grep -v grep | grep ${OPENSHIFT_DIY_IP} | wc -l)
if [ ${is_alive} -gt 0 ]; then
    if [ -f ${OPENSHIFT_TMP_DIR}/stop ]; then
        ./delegated +=P30080 -Fkill
    else
        echo delegated is alive
    fi
elif [ ! -f ${OPENSHIFT_TMP_DIR}/stop ]; then
    echo RESTART delegated
    cd ${OPENSHIFT_DATA_DIR}/delegate/
    ./delegated -r +=P30080
fi

# memory usage logging
is_alive=$(ps awhx | grep memory_usage_logging.sh | grep -v grep | grep ${OPENSHIFT_DIY_IP} | wc -l)
if [ ${is_alive} -gt 0 ]; then
    if [ -f ${OPENSHIFT_TMP_DIR}/stop ]; then
        kill $(ps awhx | grep memory_usage_logging.sh | grep -v grep | grep ${OPENSHIFT_DIY_IP} | awk '{print $2}' | head -n1)
    else
        echo memory_usage_logging is alive
    fi
elif [ ! -f ${OPENSHIFT_TMP_DIR}/stop ]; then
    echo START memory_usage_logging.sh
    ${OPENSHIFT_DATA_DIR}/scripts/memory_usage_logging.sh ${OPENSHIFT_DIY_IP}
fi

# redmine
# export PASSENGER_TEMP_DIR=${OPENSHIFT_TMP_DIR}/PassengerTempDir
process_count=$(find ${OPENSHIFT_DATA_DIR}/.gem/gems/ \
-name passenger-status -type f \
| xargs --replace={} ruby {} --verbose \
| grep Processes | awk '{print $NF}')
if [ ${process_count} = 0 ]; then
    wget --spider https://${OPENSHIFT_APP_DNS}/redmine/
fi
__HEREDOC__
chmod +x keep_process.sh

# *** mrtg ***

cat << '__HEREDOC__' > mrtg.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S)

mpstat 5 1 | grep ^Average | awk '{print $3+$4+$5+$6+$7+$8+$9+$10}' > ${OPENSHIFT_TMP_DIR}/cpu_usage_current
cd ${OPENSHIFT_DATA_DIR}/mrtg
env LANG=C ./bin/mrtg mrtg.conf
__HEREDOC__
chmod +x mrtg.sh
./mrtg.sh

# *** Tiny Tiny Rss update feeds ***

cat << '__HEREDOC__' > update_feeds.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S)

minute=$(date +%M)

if [ $(expr ${minute} % 5) -eq 0 ]; then
    ${OPENSHIFT_DATA_DIR}/php/bin/php ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss/update.php --feeds
fi
__HEREDOC__
chmod +x update_feeds.sh

# *** passenger status ***

cat << '__HEREDOC__' > passenger_status.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S)

cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"
rbenv global __RUBY_VERSION__
rbenv rehash

# export PASSENGER_TEMP_DIR=${OPENSHIFT_TMP_DIR}/PassengerTempDir
echo $(date +%Y/%m/%d" "%H:%M:%S) > ${OPENSHIFT_TMP_DIR}/passenger_status.txt
find ${OPENSHIFT_DATA_DIR}/.gem/gems/ -name passenger-status -type f \
| xargs --replace={} ruby {} --verbose >> ${OPENSHIFT_TMP_DIR}/passenger_status.txt
cp -f ${OPENSHIFT_TMP_DIR}/passenger_status.txt passenger_status.txt
__HEREDOC__
sed -i -e "s|__RUBY_VERSION__|${ruby_version}|g" passenger_status.sh
chmod +x passenger_status.sh

# *** memcached status ***

cat << '__HEREDOC__' > memcached_status.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S)

cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/
echo $(date +%Y/%m/%d" "%H:%M:%S) > ${OPENSHIFT_TMP_DIR}/memcached_status.txt
${OPENSHIFT_DATA_DIR}/local/bin/memcached-tool ${OPENSHIFT_DIY_IP}:31211 stats >> ${OPENSHIFT_TMP_DIR}/memcached_status.txt
cp -f ${OPENSHIFT_TMP_DIR}/memcached_status.txt memcached_status.txt
__HEREDOC__
chmod +x memcached_status.sh

# *** process status ***

cat << '__HEREDOC__' > process_status.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S)

cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/
echo $(date +%Y/%m/%d" "%H:%M:%S) > ${OPENSHIFT_TMP_DIR}/ps_auwx.txt
ps auwx >> ${OPENSHIFT_TMP_DIR}/ps_auwx.txt
cp -f ${OPENSHIFT_TMP_DIR}/ps_auwx.txt ps_auwx.txt
echo $(date +%Y/%m/%d" "%H:%M:%S) > ${OPENSHIFT_TMP_DIR}/ps_lwx.txt
ps lwx >> ${OPENSHIFT_TMP_DIR}/ps_lwx.txt
cp -f ${OPENSHIFT_TMP_DIR}/ps_lwx.txt ps_lwx.txt
echo $(date +%Y/%m/%d" "%H:%M:%S) > ${OPENSHIFT_TMP_DIR}/lsof.txt
lsof >> ${OPENSHIFT_TMP_DIR}/lsof.txt
cp -f ${OPENSHIFT_TMP_DIR}/lsof.txt lsof.txt
echo $(date +%Y/%m/%d" "%H:%M:%S) > ${OPENSHIFT_TMP_DIR}/lsof_i_n_P.txt
uptime >> ${OPENSHIFT_TMP_DIR}/lsof_i_n_P.txt
lsof -i -n -P >> ${OPENSHIFT_TMP_DIR}/lsof_i_n_P.txt
cp -f ${OPENSHIFT_TMP_DIR}/lsof_i_n_P.txt lsof_i_n_P.txt
__HEREDOC__
chmod +x process_status.sh

# *** cacti polling ***

cat << '__HEREDOC__' > cacti_poller.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S)

minute=$(date +%M)

if [ $(expr ${minute} % 5) -eq 1 ]; then
    ${OPENSHIFT_DATA_DIR}/php/bin/php ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti/poller.php
fi
__HEREDOC__
chmod +x cacti_poller.sh

popd > /dev/null

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

rm -rf ${OPENSHIFT_DATA_DIR}/logrotate
mkdir ${OPENSHIFT_DATA_DIR}/logrotate
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
__OPENSHIFT_LOG_DIR__production.log {
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

echo $(date +%Y/%m/%d" "%H:%M:%S) cron daily | tee -a ${OPENSHIFT_LOG_DIR}/install.log
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
./logrotate.sh

# * mysql_backup *

cat << '__HEREDOC__' > mysql_backup.sh
#!/bin/bash
mysqldump \
--host=${OPENSHIFT_MYSQL_DB_HOST} \
--port=${OPENSHIFT_MYSQL_DB_PORT} \
--user=${OPENSHIFT_MYSQL_DB_USERNAME} \
--password=${OPENSHIFT_MYSQL_DB_PASSWORD} \
-x --all-databases --events | xz > ${OPENSHIFT_DATA_DIR}/mysql_dump_$(date +%a).xz
__HEREDOC__
chmod +x mysql_backup.sh
echo mysql_backup.sh >> jobs.allow
./mysql_backup.sh

# * another server list update *

cat << '__HEREDOC__' > another_server_list_update.sh
#!/bin/bash

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"

env_home_backup=${HOME}
export HOME=${OPENSHIFT_DATA_DIR}

${OPENSHIFT_DATA_DIR}.gem/bin/rhc apps \
| grep uuid | grep -v ${OPENSHIFT_GEAR_DNS} \
| awk '{print $1,$3}' > ${OPENSHIFT_DATA_DIR}/another_server_list.txt

export HOME=${env_home_backup}

perl -pi -e 's/http/https/g' ${OPENSHIFT_DATA_DIR}/another_server_list.txt

cp ${OPENSHIFT_DATA_DIR}/another_server_list.txt ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/
__HEREDOC__
chmod +x another_server_list_update.sh
echo another_server_list_update.sh >> jobs.allow
./another_server_list_update.sh

popd > /dev/null

# *** hourly ***

echo $(date +%Y/%m/%d" "%H:%M:%S) cron hourly | tee -a ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/hourly > /dev/null
rm -f *
touch jobs.deny

# * mysql record count top 30 *

cat << '__HEREDOC__' > record_count_top_30_sql.txt
SELECT T1.*
  FROM information_schema.TABLES T1
 WHERE T1.TABLE_ROWS IS NOT NULL
   AND T1.TABLE_ROWS > 0
   AND T1.TABLE_SCHEMA NOT IN ('performance_schema', 'mysql')
 ORDER BY T1.TABLE_ROWS DESC
 LIMIT 0, 30
__HEREDOC__

cat << '__HEREDOC__' > record_count_top_30.sh
#!/bin/bash
export TZ=JST-9

mysql --user "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
--host "${OPENSHIFT_MYSQL_DB_HOST}" \
--port "${OPENSHIFT_MYSQL_DB_PORT}"
--html < record_count_top_30_sql.txt > record_count_top_30.html
__HEREDOC__
chmod +x record_count_top_30.sh
echo record_count_top_30.sh >> jobs.allow

# * du *

cat << '__HEREDOC__' > du.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S) > ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/du.txt
echo >> ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/du.txt
du ${OPENSHIFT_HOMEDIR} >> ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/du.txt
__HEREDOC__
chmod +x du.sh
echo du.sh >> jobs.allow

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
delegate_email_account=$(cat ${OPENSHIFT_DATA_DIR}/params/delegate_email_account)
delegate_email_password=$(cat ${OPENSHIFT_DATA_DIR}/params/delegate_email_password)
delegate_pop_server=$(cat ${OPENSHIFT_DATA_DIR}/params/delegate_pop_server)
curl -LI --basic -u ${delegate_email_account}:${delegate_email_password} \
https://${OPENSHIFT_DIY_IP}:30080/mail/+pop.${delegate_email_account}.${delegate_pop_server}/
__HEREDOC__
if [ ! ${delegate_email_account} = 'none' ]; then
chmod +x delegate.sh
# echo delegate.sh >> jobs.allow
fi
popd > /dev/null

# *** minutely ***

echo $(date +%Y/%m/%d" "%H:%M:%S) cron minutely | tee -a ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null
rm -f *
touch jobs.deny

cat << '__HEREDOC__' > minutely_jobs.sh
#!/bin/bash

export TZ=JST-9
echo $(date +%Y/%m/%d" "%H:%M:%S)

pushd ${OPENSHIFT_DATA_DIR}/scripts > /dev/null

./another_server_check.sh >>${OPENSHIFT_LOG_DIR}/another_server_check.sh.log 2>&1 &
./beacon.sh >>${OPENSHIFT_LOG_DIR}/beacon.sh.log 2>&1 &
./cacti_poller.sh >>${OPENSHIFT_LOG_DIR}/cacti_poller.sh.log 2>&1 &
./keep_process.sh >>${OPENSHIFT_LOG_DIR}/keep_process.sh.log 2>&1 &
./logrotate.sh >>${OPENSHIFT_LOG_DIR}/logrotate.sh.log 2>&1 &
./memcached_status.sh >>${OPENSHIFT_LOG_DIR}/memcached_status.sh.log 2>&1 &
./mrtg.sh >>${OPENSHIFT_LOG_DIR}/mrtg.sh.log 2>&1 &
# ./my_server_check.sh >>${OPENSHIFT_LOG_DIR}/my_server_check.sh.log 2>&1 &
./passenger_status.sh >>${OPENSHIFT_LOG_DIR}/passenger_status.sh.log 2>&1 &
./process_status.sh >>${OPENSHIFT_LOG_DIR}/process_status.sh.log 2>&1 &
./redmine_repository_check.sh >>${OPENSHIFT_LOG_DIR}/redmine_repository_check.sh.log 2>&1 &
./update_feeds.sh >>${OPENSHIFT_LOG_DIR}/update_feeds.sh.log 2>&1 &

popd > /dev/null
__HEREDOC__
chmod +x minutely_jobs.sh
echo minutely_jobs.sh >> jobs.allow

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo $(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename $0) | tee -a ${OPENSHIFT_LOG_DIR}/install.log
