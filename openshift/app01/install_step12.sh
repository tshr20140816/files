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
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** cron *****

# *** daily ***

echo `date +%Y/%m/%d" "%H:%M:%S` cron daily >> ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/daily > /dev/null
rm -f *
touch jobs.deny

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

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)" 

rake redmine:fetch_changesets RAILS_ENV=production
__HEREDOC__
chmod +x redmine_repository_check.sh
echo redmine_repository_check.sh >> jobs.allow

popd > /dev/null

# *** minutely ***

echo `date +%Y/%m/%d" "%H:%M:%S` cron minutely >> ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null
rm -f *
touch jobs.deny

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
is_alive=`ps -ef | grep memcached | grep -v grep | wc -l`
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

echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 11 Finish >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** start *****

# kill `netstat -anpt 2>/dev/null | grep ${OPENSHIFT_DIY_IP} | grep LISTEN | awk '{print $7}' | awk -F/ '{print $1}'`
kill `ps auwx  2>/dev/null | grep testrubyserver.rb | grep -v grep | awk '{print $2}'`
export TZ=JST-9
${OPENSHIFT_DATA_DIR}/apache/bin/apachectl -k graceful
pushd ${OPENSHIFT_DATA_DIR}/delegate
./delegated -r +=P30080
popd > /dev/null
${OPENSHIFT_DATA_DIR}/memcached/bin/memcached -l ${OPENSHIFT_DIY_IP} -p 31211 -d

wget --spider https://${OPENSHIFT_APP_DNS}/
wget --spider https://${OPENSHIFT_APP_DNS}/redmine/
sleep 5s

${OPENSHIFT_REPO_DIR}/.openshift/cron/hourly/webalizer.sh

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/memcached-tool ./
chmod +x memcached-tool
./memcached-tool ${OPENSHIFT_DIY_IP}:31211 dump
./memcached-tool ${OPENSHIFT_DIY_IP}:31211 stats
./memcached-tool ${OPENSHIFT_DIY_IP}:31211 display
popd > /dev/null

set +x

echo https://${OPENSHIFT_APP_DNS}/wordpress/wp-admin/install.php
echo https://${OPENSHIFT_APP_DNS}/ttrss/install/ ttrssuser/${ttrssuser_password} ttrss ${OPENSHIFT_MYSQL_DB_HOST} admin/password
echo https://${OPENSHIFT_APP_DNS}/mail/
echo https://${OPENSHIFT_APP_DNS}/webalizer/
echo https://${OPENSHIFT_APP_DNS}/mrtg/
echo https://${OPENSHIFT_APP_DNS}/redmine/
