#!/bin/bash

source functions.sh
function010 stop
[ $? -eq 0 ] || exit

pushd ${OPENSHIFT_DATA_DIR}/scripts > /dev/null

# ***** YUI Compressor *****

cat << '__HEREDOC__' > yuicompressor.sh
#!/bin/bash

export TZ=JST-9

#!/bin/bash

export TZ=JST-9

echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ ${1}"

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
uuid=${OPENSHIFT_APP_UUID}$$
suffix=$(date '+%Y%m%d')

target_file=${1}

while read LINE
do
    # if [ $(pgrep -fl curl | grep ${LINE} | grep -c -v grep) -eq 0 ]; then
    if [ $(pgrep -fl curl | grep -c ${LINE}) -eq 0 ]; then
        server=${LINE}
        break
    fi
done < <(sort --random-sort ${OPENSHIFT_DATA_DIR}/params/fqdn.txt)

compressed_file=./$(basename ${target_file}).$$
rm -f ${compressed_file}

path=$(echo ${target_file} | sed -e "s|${OPENSHIFT_HOMEDIR}||g")
echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ server=${server} target_file=${target_file} suffix=${uuid} path=${path} compressed_file=${compressed_file}" \
 | tee -a ${OPENSHIFT_LOG_DIR}/yuicompressor.log
curl https://${server}/yuicompressor.php -F "file=@${target_file}" -F "suffix=${uuid}" -F "path=${path}" -o ${compressed_file}

if [ ! -f ${compressed_file} ]; then
    echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ NOT CHANGED (ERROR) ${target_file}" \
     | tee -a ${OPENSHIFT_LOG_DIR}/yuicompressor.log
else
    size_original=$(wc -c < ${target_file})
    size_compiled=$(wc -c < ${compressed_file})
    if [ ${size_original} -gt ${size_compiled} ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ CHANGED ${size_original} ${size_compiled} ${target_file}" \
         | tee -a ${OPENSHIFT_LOG_DIR}/yuicompressor.log
        mv -f ${target_file} ${target_file}.${suffix}
        mv -f ${compressed_file} ${target_file}
    else
        echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ NOT CHANGED (SIZE NOT DOWNED) ${size_original} ${size_compiled} ${target_file}" \
         | tee -a ${OPENSHIFT_LOG_DIR}/yuicompressor.log
        rm -f ${compressed_file}
    fi
fi
popd > /dev/null
__HEREDOC__
chmod +x yuicompressor.sh &

# ***** Closure Compiler *****

cat << '__HEREDOC__' > closure_compiler.sh
#!/bin/bash

export TZ=JST-9

echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ ${1}"

uuid=${OPENSHIFT_APP_UUID}$$
suffix=$(date '+%Y%m%d')
target_file=${1}
[ -f ${target_file}.${suffix} ] && exit
[ -f ${target_file}.$(date -d '1 days ago' '+%Y%m%d')) ] && exit

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
while read LINE
do
    # if [ $(pgrep -fl curl | grep ${LINE} | grep -c -v grep) -eq 0 ]; then
    if [ $(pgrep -fl curl | grep -c ${LINE}) -eq 0 ]; then
        server=${LINE}
        break
    fi
done < <(sort --random-sort ${OPENSHIFT_DATA_DIR}/params/fqdn.txt)

rm -f result.${uuid}.zip

path=$(echo ${target_file} | sed -e "s|${OPENSHIFT_HOMEDIR}||g")
echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ server=${server} target_file=${target_file} suffix=${uuid} path=${path} result.zip=result.${uuid}.zip" \
 | tee -a ${OPENSHIFT_LOG_DIR}/closure_compiler.log
curl https://${server}/closure_compiler.php -F "file=@${target_file}" -F "suffix=${uuid}" -F "path=${path}" -o result.${uuid}.zip

rm -f compiled.${uuid}.js
rm -f result.${uuid}.txt

unzip result.${uuid}.zip
if [ ! -f result.${uuid}.txt ]; then
    echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ NOT CHANGED (ERROR) ${target_file} RESULT FILE NOT FOUND" \
     | tee -a ${OPENSHIFT_LOG_DIR}/closure_compiler.log
elif [ ! -f compiled.${uuid}.js ]; then
    echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ NOT CHANGED (ERROR) ${target_file} $(tail -n 1 result.${uuid}.txt)" \
     | tee -a ${OPENSHIFT_LOG_DIR}/closure_compiler.log
elif [ "$(cat result.${uuid}.txt)" = "0 error(s), 0 warning(s)" ]; then
    size_original=$(wc -c < ${1})
    size_compiled=$(wc -c < compiled.${uuid}.js)
    if [ ${size_original} -gt ${size_compiled} ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ CHANGED ${size_original} ${size_compiled} ${1}" \
         | tee -a ${OPENSHIFT_LOG_DIR}/closure_compiler.log
        mv -f ${1} ${1}.${suffix}
        mv -f compiled.${uuid}.js ${1}
    else
        echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ NOT CHANGED (SIZE NOT DOWNED) ${size_original} ${size_compiled} ${1}" \
         | tee -a ${OPENSHIFT_LOG_DIR}/closure_compiler.log
    fi
else
    echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ NOT CHANGED (ERROR OR WARNING) ${target_file} $(tail -n 1 result.${uuid}.txt)" \
     | tee -a ${OPENSHIFT_LOG_DIR}/closure_compiler.log
fi

rm -f compiled.${uuid}.js
rm -f result.${uuid}.txt
rm -f result.${uuid}.zip
popd > /dev/null
__HEREDOC__
chmod +x closure_compiler.sh &

# ***** optipng *****

cat << '__HEREDOC__' > optipng.sh
#!/bin/bash

export TZ=JST-9

echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ ${1}"
echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ $(oo-cgroup-read memory.usage_in_bytes | awk '{printf "%\047d\n", $1}')" \
 >> ${OPENSHIFT_LOG_DIR}/optipng.log
while :
do
    usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
    if [ ${usage_in_bytes} -gt 400000000 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ $(oo-cgroup-read memory.usage_in_bytes | awk '{printf "%\047d\n", $1}') waiting" \
         >> ${OPENSHIFT_LOG_DIR}/optipng.log
        sleep 5s
    else
        break
    fi
done
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
suffix=$(date '+%Y%m%d')
target_file=${1}
compressed_file=./$(basename ${target_file}).$$
rm -f ${compressed_file}
# -o7 -zm1-9
${OPENSHIFT_DATA_DIR}/optipng/bin/optipng \
 -o7 \
 -out ${compressed_file} \
 ${target_file} \
 >> ${OPENSHIFT_LOG_DIR}/optipng.log 2>&1
if [ ! -f ${compressed_file} ]; then
    echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ NOT CHANGED (ERROR) ${target_file}" \
     >> ${OPENSHIFT_LOG_DIR}/optipng.log
else
    size_original=$(wc -c < ${target_file})
    size_compiled=$(wc -c < ${compressed_file})
    if [ ${size_original} -gt ${size_compiled} ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ CHANGED ${size_original} ${size_compiled} ${target_file}" \
         >> ${OPENSHIFT_LOG_DIR}/optipng.log
        mv -f ${target_file} ${target_file}.${suffix}
        mv -f ${compressed_file} ${target_file}
    else
        echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ NOT CHANGED (SIZE NOT DOWNED) ${size_original} ${size_compiled} ${target_file}" \
         >> ${OPENSHIFT_LOG_DIR}/optipng.log
        rm -f ${compressed_file}
    fi
fi
popd > /dev/null
__HEREDOC__
chmod +x optipng.sh &

# ***** memory usage logging *****

cat << '__HEREDOC__' > memory_usage_logging.sh
#!/bin/bash

# source ${OPENSHIFT_DATA_DIR}/github/openshift/app01/functions.sh

export TZ=JST-9
url="$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy"
shell_name=$(basename "${0}")
while :
do
    dt=$(date +%Y/%m/%d" "%H:%M:%S)
    usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
    usage_in_bytes_format=$(echo ${usage_in_bytes} | awk '{printf "%\047d\n", $0}')
    failcnt=$(oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $0}')
    echo ${dt} ${usage_in_bytes_format} ${failcnt} >> ${OPENSHIFT_LOG_DIR}/memory_usage.log
    tail -n 100 ${OPENSHIFT_LOG_DIR}/memory_usage.log \
     | sort -r > ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/memory_usage_tail_100_sort_r.log
    for size in 300 350 400 450 500
    do
        filename=${OPENSHIFT_TMP_DIR}/memory_over_${size}M
        [ ${usage_in_bytes} -gt $((size * (10**6))) ] && touch ${filename} || rm -f ${filename}
    done
    [ -f ${OPENSHIFT_TMP_DIR}/stop ] && exit || sleep 1s
    day=$(head -n 1 ${OPENSHIFT_LOG_DIR}/memory_usage.log)
    day=${day:8:2}
    if [ ${day} != $(date +%d) ]; then
        # function030 "cron=minutely&shell_name=${shell_name}&check_point=param&day=${day}&date=$(date +%d)"
        file_name=${OPENSHIFT_APP_DNS}.memory_usage.log.$(date +%w).xz
        mkdir ${OPENSHIFT_LOG_DIR}/backup 2> /dev/null
        # function030 "cron=minutely&shell_name=${shell_name}&check_point=xz"
        pushd ${OPENSHIFT_LOG_DIR} > /dev/null
        xz -z9ef memory_usage.log
        mv -f memory_usage.log.xz backup/${file_name}
        popd > /dev/null
        # function030 "cron=minutely&shell_name=${shell_name}&check_point=cadaver"
        log_file_name=${OPENSHIFT_LOG_DIR}/cadaver.log
        ls -lhg --full-time ${OPENSHIFT_LOG_DIR}/backup/ | tee ${log_file_name}
        remote_dir=/users/$(cat ${OPENSHIFT_DATA_DIR}/params/hidrive_account)
        echo "$(date +%Y/%m/%d" "%H:%M:%S) START memory_usage_logging.sh" >> ${OPENSHIFT_LOG_DIR}/cadaver_all.log
        ${OPENSHIFT_DATA_DIR}/scripts/./cadaver_put.sh ${OPENSHIFT_LOG_DIR}/backup/ ${remote_dir} ${file_name} | tee -a ${log_file_name}
        if [ $(grep -c -e succeeded ${log_file_name}) -eq 1 ]; then
            rm -f ${OPENSHIFT_LOG_DIR}/backup/${file_name}
        fi
        cat ${log_file_name} | tr -d "\b" >> ${OPENSHIFT_LOG_DIR}/cadaver_all.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) FINISH memory_usage_logging.sh" >> ${OPENSHIFT_LOG_DIR}/cadaver_all.log
        # function030 "cron=minutely&shell_name=${shell_name}&check_point=done"
    fi
done
__HEREDOC__
chmod +x memory_usage_logging.sh &

# ***** cron scripts *****

# *** redmine repository check ***

cat << '__HEREDOC__' > redmine_repository_check.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S
minute=$((10#$(date +%M)))
dt=$(date +%Y/%m/%d" "%H:%M:%S)

if [ $((minute % 5)) -eq 2 ]; then
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
chmod +x redmine_repository_check.sh &

# *** my server check ***

cat << '__HEREDOC__' > my_server_check.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S

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
chmod +x my_server_check.sh &

# *** web beacon ***

cat << '__HEREDOC__' > beacon.sh
#!/bin/bash

export TZ=JST-9
echo "$(date +%Y/%m/%d" "%H:%M:%S) $(curl -LI __WEB_BEACON_SERVER__beacon.txt?${OPENSHIFT_APP_DNS} -s | head -n1)"
__HEREDOC__
web_beacon_server=$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)
sed -i -e "s|__WEB_BEACON_SERVER__|${web_beacon_server}|g" beacon.sh
cat beacon.sh
chmod +x beacon.sh &

# *** keep_process ***

cat << '__HEREDOC__' > keep_process.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S

# memcached
is_alive=$(ps awhx | grep bin/memcached | grep -v grep | grep -c ${OPENSHIFT_DIY_IP})
if [ ${is_alive} -gt 0 ]; then
    if [ -f ${OPENSHIFT_TMP_DIR}/stop ]; then
        kill $(ps awhx | grep bin/memcached | grep -v grep | grep ${OPENSHIFT_DIY_IP} | awk '{print $2}' | head -n1)
    else
        echo memcached is alive
    fi
elif [ ! -f ${OPENSHIFT_TMP_DIR}/stop ]; then
    echo RESTART memcached
    cd ${OPENSHIFT_DATA_DIR}/memcached/
    ./bin/memcached -l ${OPENSHIFT_DIY_IP} -p 31211 -U 0 -m 60 -C -d >>${OPENSHIFT_LOG_DIR}/memcached.log 2>&1
fi

# delegated port 30080
is_alive=$(ps awhx | grep delegated | grep -v grep | grep -c ${OPENSHIFT_DIY_IP}:30080)
if [ ${is_alive} -gt 0 ]; then
    if [ -f ${OPENSHIFT_TMP_DIR}/stop ]; then
        ./delegated +=P30080 -Fkill
    else
        echo delegated is alive
    fi
elif [ ! -f ${OPENSHIFT_TMP_DIR}/stop ]; then
    echo RESTART delegated 30080
    cd ${OPENSHIFT_DATA_DIR}/delegate/
    ./delegated -r +=P30080
fi

# delegated port 33128
is_alive=$(ps awhx | grep delegated | grep -v grep | grep -c ${OPENSHIFT_DIY_IP}:33128)
if [ ${is_alive} -gt 0 ]; then
    if [ -f ${OPENSHIFT_TMP_DIR}/stop ]; then
        ./delegated +=P33128 -Fkill
    else
        echo delegated is alive
    fi
elif [ ! -f ${OPENSHIFT_TMP_DIR}/stop ]; then
    echo RESTART delegated 33128
    cd ${OPENSHIFT_DATA_DIR}/delegate/
    ./delegated -r +=P33128
fi

# redmine
# export PASSENGER_TEMP_DIR=${OPENSHIFT_TMP_DIR}/PassengerTempDir
# process_count=$(find ${OPENSHIFT_DATA_DIR}/.gem/gems/ \
#  -name passenger-status -type f \
#  | xargs -i ruby {} --verbose \
#  | grep Processes | awk '{print $NF}')
process_count=$(${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-status --verbose | grep Processes | awk '{print $NF}')
if [ ${process_count} = 0 ]; then
    wget --spider https://${OPENSHIFT_APP_DNS}/redmine/
fi

# memory usage logging
is_alive=$(ps awhx | grep memory_usage_logging.sh | grep -v grep | grep -c ${OPENSHIFT_DIY_IP})
if [ ${is_alive} -gt 0 ]; then
    if [ -f ${OPENSHIFT_TMP_DIR}/stop ]; then
        kill $(ps awhx | grep memory_usage_logging.sh | grep -v grep | grep ${OPENSHIFT_DIY_IP} | awk '{print $2}' | head -n1)
    else
        echo memory_usage_logging is alive
    fi
elif [ ! -f ${OPENSHIFT_TMP_DIR}/stop ]; then
    echo START memory_usage_logging.sh
    nohup ${OPENSHIFT_DATA_DIR}/scripts/memory_usage_logging.sh ${OPENSHIFT_DIY_IP} &
fi
__HEREDOC__
chmod +x keep_process.sh &

# *** mrtg ***

cat << '__HEREDOC__' > mrtg.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S

mpstat 5 1 | grep ^Average | awk '{print $3+$4+$5+$6+$7+$8+$9+$10}' > ${OPENSHIFT_TMP_DIR}/cpu_usage_current
cd ${OPENSHIFT_DATA_DIR}/mrtg
env LANG=C ./bin/mrtg mrtg.conf
__HEREDOC__
chmod +x mrtg.sh
./mrtg.sh &

# *** Tiny Tiny Rss update feeds ***

cat << '__HEREDOC__' > update_feeds.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S

minute=$((10#$(date +%M)))

if [ $((minute % 5)) -eq 0 ]; then
    # appspot.com への負荷を下げる
    find ${OPENSHIFT_DATA_DIR}/delegate/cache -name '*' -type f -print | grep -v appspot.com | xargs rm
    # 階層が深いと少しずつ
    find ${OPENSHIFT_DATA_DIR}/delegate/cache -name '*' -type d -empty -print | xargs rm -rf
    ${OPENSHIFT_DATA_DIR}/php/bin/php ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss/update.php --feeds
    # pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss >/dev/null
    # ${OPENSHIFT_DATA_DIR}/php/bin/php ./update_daemon2.php --tasks 5
    # popd >/dev/null
fi
__HEREDOC__
chmod +x update_feeds.sh &

# *** passenger status ***

cat << '__HEREDOC__' > passenger_status.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S

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
# find ${OPENSHIFT_DATA_DIR}/.gem/gems/ -name passenger-status -type f \
#  | xargs -i ruby {} --verbose >> ${OPENSHIFT_TMP_DIR}/passenger_status.txt
${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-status --verbose >> ${OPENSHIFT_TMP_DIR}/passenger_status.txt
cp -f ${OPENSHIFT_TMP_DIR}/passenger_status.txt passenger_status.txt
__HEREDOC__
sed -i -e "s|__RUBY_VERSION__|${ruby_version}|g" passenger_status.sh
chmod +x passenger_status.sh &

# *** memcached status ***

cat << '__HEREDOC__' > memcached_status.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S

cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/
echo $(date +%Y/%m/%d" "%H:%M:%S) > ${OPENSHIFT_TMP_DIR}/memcached_status.txt
${OPENSHIFT_DATA_DIR}/local/bin/memcached-tool ${OPENSHIFT_DIY_IP}:31211 stats >> ${OPENSHIFT_TMP_DIR}/memcached_status.txt
cp -f ${OPENSHIFT_TMP_DIR}/memcached_status.txt memcached_status.txt
__HEREDOC__
chmod +x memcached_status.sh &

# *** process status ***

cat << '__HEREDOC__' > process_status.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S

cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/
echo $(date +%Y/%m/%d" "%H:%M:%S) > ${OPENSHIFT_TMP_DIR}/ps_auwx.txt
ps auwx >> ${OPENSHIFT_TMP_DIR}/ps_auwx.txt
cp -f ${OPENSHIFT_TMP_DIR}/ps_auwx.txt ps_auwx.txt
echo $(date +%Y/%m/%d" "%H:%M:%S) > ${OPENSHIFT_TMP_DIR}/ps_lwx.txt
ps lwx --sort -rss >> ${OPENSHIFT_TMP_DIR}/ps_lwx.txt
cp -f ${OPENSHIFT_TMP_DIR}/ps_lwx.txt ps_lwx.txt
echo $(date +%Y/%m/%d" "%H:%M:%S) > ${OPENSHIFT_TMP_DIR}/lsof.txt
lsof >> ${OPENSHIFT_TMP_DIR}/lsof.txt
cp -f ${OPENSHIFT_TMP_DIR}/lsof.txt lsof.txt
echo $(date +%Y/%m/%d" "%H:%M:%S) > ${OPENSHIFT_TMP_DIR}/lsof_i_n_P.txt
uptime >> ${OPENSHIFT_TMP_DIR}/lsof_i_n_P.txt
lsof -i -n -P >> ${OPENSHIFT_TMP_DIR}/lsof_i_n_P.txt
cp -f ${OPENSHIFT_TMP_DIR}/lsof_i_n_P.txt lsof_i_n_P.txt
echo $(date +%Y/%m/%d" "%H:%M:%S) > ${OPENSHIFT_TMP_DIR}/listen_port.txt
rhc-list-ports >> ${OPENSHIFT_TMP_DIR}/listen_port.txt 2>&1
cp -f ${OPENSHIFT_TMP_DIR}/listen_port.txt listen_port.txt
__HEREDOC__
chmod +x process_status.sh &

# *** cacti polling ***

cat << '__HEREDOC__' > cacti_poller.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S

minute=$((10#$(date +%M)))

if [ $((minute % 5)) -eq 1 ]; then
    ${OPENSHIFT_DATA_DIR}/php/bin/php ${OPENSHIFT_DATA_DIR}/apache/htdocs/cacti/poller.php
fi
__HEREDOC__
chmod +x cacti_poller.sh &

cat << '__HEREDOC__' > record_count_top_30_sql.txt
SELECT T1.*
  FROM information_schema.TABLES T1
 WHERE T1.TABLE_ROWS IS NOT NULL
   AND T1.TABLE_ROWS > 0
   AND T1.TABLE_SCHEMA NOT IN ('performance_schema', 'mysql')
 ORDER BY T1.TABLE_ROWS DESC
 LIMIT 0, 30
__HEREDOC__

cat << '__HEREDOC__' > redmine_sql1.txt
DELETE
  FROM changesets
 WHERE id NOT IN (
                   SELECT Q1.id
                     FROM (
                            SELECT MAX(T1.id) id
                              FROM changesets T1
                             GROUP BY T1.repository_id
                          ) Q1
                 )
__HEREDOC__

cat << '__HEREDOC__' > redmine_sql2.txt
DELETE
  FROM changes
 WHERE changeset_id NOT IN (
                             SELECT T1.id
                               FROM changesets T1
                           )
__HEREDOC__

cat << '__HEREDOC__' > redmine_sql3.txt
SELECT COUNT('X')
  FROM changesets
__HEREDOC__

cat << '__HEREDOC__' > redmine_sql4.txt
SELECT COUNT('X')
  FROM changes
__HEREDOC__

popd > /dev/null

# ***** cron *****

# *** daily ***

echo "$(date +%Y/%m/%d" "%H:%M:%S) cron daily" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/daily > /dev/null
rm -f ./*
touch jobs.deny

# * mysql_backup *

cat << '__HEREDOC__' > mysql_backup.sh
#!/bin/bash

pushd ${OPENSHIFT_DATA_DIR}

dump_file_name=${OPENSHIFT_APP_DNS}.mysql_dump_$(date +%a).xz

mysqldump \
 --host=${OPENSHIFT_MYSQL_DB_HOST} \
 --port=${OPENSHIFT_MYSQL_DB_PORT} \
 --user=${OPENSHIFT_MYSQL_DB_USERNAME} \
 --password=${OPENSHIFT_MYSQL_DB_PASSWORD} \
 -x --all-databases --events | xz > ${dump_file_name}

echo "$(date +%Y/%m/%d" "%H:%M:%S) START mysql_backup.sh" >> ${OPENSHIFT_LOG_DIR}/cadaver_all.log
log_file_name=${OPENSHIFT_LOG_DIR}/cadaver.log
ls -lhg --full-time | tee ${log_file_name}
remote_dir=/users/$(cat ${OPENSHIFT_DATA_DIR}/params/hidrive_account)
./scripts/cadaver_put.sh ${OPENSHIFT_DATA_DIR} ${remote_dir} ${dump_file_name} | tee -a ${log_file_name}
if [ $(grep -c -e succeeded ${log_file_name}) -eq 1 ]; then
    echo "OK"
    rm ${dump_file_name}
else
    echo "NG"
fi
cat ${log_file_name} | tr -d "\b" >> ${OPENSHIFT_LOG_DIR}/cadaver_all.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) FINISH mysql_backup.sh" >> ${OPENSHIFT_LOG_DIR}/cadaver_all.log
popd
__HEREDOC__
chmod +x mysql_backup.sh
echo mysql_backup.sh >> jobs.allow
./mysql_backup.sh &

# * backup log files *

cat << '__HEREDOC__' > bakup_log_files.sh
#!/bin/bash

export TZ=JST-9

weekday=$(date --date '2 days ago' +%w)

mkdir ${OPENSHIFT_LOG_DIR}/backup 2> /dev/null
pushd ${OPENSHIFT_LOG_DIR} > /dev/null
for file in *log.${weekday}
do
    set -x
    xz -z9ef ${file}
    mv -f ${file}.xz ${OPENSHIFT_LOG_DIR}/backup/${OPENSHIFT_APP_DNS}.${file}.xz
    set +x
done
popd > /dev/null
pushd ${OPENSHIFT_DATA_DIR}/apache/logs/ > /dev/null
for file in *log.${weekday}
do
    set -x
    xz -z9ef ${file}
    mv -f ${file}.xz ${OPENSHIFT_LOG_DIR}/backup/${OPENSHIFT_APP_DNS}.${file}.xz
    set +x
done
popd > /dev/null
pushd ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/log/ > /dev/null
if [ -f production.log.$(date --date '2 days ago' +%Y%m%d) ]; then
    set -x
    mv -f production.log.$(date --date '2 days ago' +%Y%m%d) production.log.${weekday}
    xz -z9ef production.log.${weekday}
    mv -f production.log.${weekday} ${OPENSHIFT_LOG_DIR}/backup/${OPENSHIFT_APP_DNS}.${file}.xz
    set +x
fi
popd > /dev/null
pushd ${OPENSHIFT_LOG_DIR}/backup/ > /dev/null
log_file_name=${OPENSHIFT_LOG_DIR}/cadaver.log
remote_dir=/users/$(cat ${OPENSHIFT_DATA_DIR}/params/hidrive_account)
for file in *log.${weekday}.xz
do
    echo "$(date +%Y/%m/%d" "%H:%M:%S) START bakup_log_files.sh ${file}" >> ${OPENSHIFT_LOG_DIR}/cadaver_all.log
    ${OPENSHIFT_DATA_DIR}/scripts/./cadaver_put.sh ${OPENSHIFT_LOG_DIR}/backup/ ${remote_dir} ${file} | tee ${log_file_name}
    if [ $(grep -c -e succeeded ${log_file_name}) -eq 1 ]; then
        echo "OK ${file}"
        rm ${file}
    else
        echo "NG ${file}"
    fi
    cat ${log_file_name} | tr -d "\b" >> ${OPENSHIFT_LOG_DIR}/cadaver_all.log
    echo "$(date +%Y/%m/%d" "%H:%M:%S) FINISH bakup_log_files.sh ${file}" >> ${OPENSHIFT_LOG_DIR}/cadaver_all.log
done
popd > /dev/null
__HEREDOC__
sed -i -e "s|__REDMINE_VERSION__|${redmine_version}|g" bakup_log_files.sh
chmod +x bakup_log_files.sh &
echo bakup_log_files.sh >> jobs.allow

popd > /dev/null

# *** hourly ***

echo "$(date +%Y/%m/%d" "%H:%M:%S) cron hourly" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/hourly > /dev/null
rm -f ./*
touch jobs.deny

# * redmine repository data maintenance *

cat << '__HEREDOC__' > redmine_repository_data_maintenance.sh
#!/bin/bash
export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S

connection_string=$(cat << __HEREDOC_2__
--user=${OPENSHIFT_MYSQL_DB_USERNAME}
--password=${OPENSHIFT_MYSQL_DB_PASSWORD}
--host=${OPENSHIFT_MYSQL_DB_HOST}
--port=${OPENSHIFT_MYSQL_DB_PORT}
--database=redmine
__HEREDOC_2__
)

for index in 1 2 3 4
do
    mysql ${connection_string} --execute="$(cat ${OPENSHIFT_DATA_DIR}/scripts/redmine_sql${index}.txt)"
done

__HEREDOC__
chmod +x redmine_repository_data_maintenance.sh &
echo redmine_repository_data_maintenance.sh >> jobs.allow

# * mysql record count top 30 *

cat << '__HEREDOC__' > record_count_top_30.sh
#!/bin/bash
export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S
hh=$(date +%H)

connection_string=$(cat << __HEREDOC_2__
--user=${OPENSHIFT_MYSQL_DB_USERNAME}
--password=${OPENSHIFT_MYSQL_DB_PASSWORD}
--host=${OPENSHIFT_MYSQL_DB_HOST}
--port=${OPENSHIFT_MYSQL_DB_PORT}
__HEREDOC_2__
)

mysql ${connection_string} \
 --html < ${OPENSHIFT_DATA_DIR}/scripts/record_count_top_30_sql.txt \
 > ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/record_count_top_30_${hh}.html

mysql ${connection_string} \
 --html \
 --execute="SHOW GLOBAL STATUS" \
 > ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/mysql_global_status_${hh}.html
__HEREDOC__
chmod +x record_count_top_30.sh &
echo record_count_top_30.sh >> jobs.allow

# * du *

cat << '__HEREDOC__' > du.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S | tee ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/du.txt
echo >> ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/du.txt
du ${OPENSHIFT_HOMEDIR} >> ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/du.txt
__HEREDOC__
chmod +x du.sh &
echo du.sh >> jobs.allow

# * webalizer *

cat << '__HEREDOC__' > webalizer.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S
cd ${OPENSHIFT_DATA_DIR}/webalizer
./bin/webalizer -c ./etc/webalizer.conf ${OPENSHIFT_DATA_DIR}/apache/logs/access_log.$(date --date yesterday '+%w')
./bin/webalizer -c ./etc/webalizer.conf ${OPENSHIFT_DATA_DIR}/apache/logs/access_log
__HEREDOC__
chmod +x webalizer.sh &
echo webalizer.sh >> jobs.allow

# * wordpress *

cat << '__HEREDOC__' > wordpress.sh
#!/bin/bash

export TZ=JST-9

date +%Y/%m/%d" "%H:%M:%S

connection_string_no_db=$(cat << __HEREDOC_2__
--user=${OPENSHIFT_MYSQL_DB_USERNAME}
--password=${OPENSHIFT_MYSQL_DB_PASSWORD}
--host=${OPENSHIFT_MYSQL_DB_HOST}
--port=${OPENSHIFT_MYSQL_DB_PORT}
--silent --batch --skip-column-names
__HEREDOC_2__
)

connection_string=$(cat << __HEREDOC_2__
${connection_string_no_db}
--database=wordpress
__HEREDOC_2__
)

sql=$(cat << '__HEREDOC_2__'
SELECT T1.TABLE_NAME
  FROM information_schema.TABLES T1
 WHERE T1.TABLE_TYPE = 'BASE TABLE'
   AND T1.TABLE_SCHEMA = 'wordpress'
   AND T1.ENGINE = 'InnoDB'
   AND T1.ROW_FORMAT <> 'Compressed'
 ORDER BY T1.TABLE_NAME
__HEREDOC_2__
)

tables=$(mysql ${connection_string_no_db} \
 --skip-column-names \
 --database=information_schema \
 --execute="${sql}")

for table in ${tables[@]}; do
    mysql ${connection_string} \
     --execute="SET GLOBAL innodb_file_per_table=1;SET GLOBAL innodb_file_format=Barracuda;"
    break
done

for table in ${tables[@]}; do
    for size in 1 2 4 8 16; do
        mysql ${connection_string} \
         --execute="ALTER TABLE ${table} ENGINE=InnoDB ROW_FORMAT=compressed KEY_BLOCK_SIZE=${size};"
        if [ $? -eq 0 ]; then
            echo "${table} KEY_BLOCK_SIZE=${size}"
            break
        fi
    done
done
__HEREDOC__
chmod +x wordpress.sh &
echo wordpress.sh >> jobs.allow

# * baikal *
cp ${OPENSHIFT_DATA_DIR}/download_files/ical_multi.sh ${OPENSHIFT_DATA_DIR}/scripts/
chmod +x ${OPENSHIFT_DATA_DIR}/scripts/ical_multi.sh
cat << '__HEREDOC__' > baikal.sh
#!/bin/bash

export TZ=JST-9

date +%Y/%m/%d" "%H:%M:%S

connection_string_no_db=$(cat << __HEREDOC_2__
--user=${OPENSHIFT_MYSQL_DB_USERNAME}
--password=${OPENSHIFT_MYSQL_DB_PASSWORD}
--host=${OPENSHIFT_MYSQL_DB_HOST}
--port=${OPENSHIFT_MYSQL_DB_PORT}
--silent --batch --skip-column-names
__HEREDOC_2__
)

connection_string=$(cat << __HEREDOC_2__
${connection_string_no_db}
--database=baikal
__HEREDOC_2__
)

sql=$(cat << '__HEREDOC_2__'
SELECT T1.TABLE_NAME
  FROM information_schema.TABLES T1
 WHERE T1.TABLE_TYPE = 'BASE TABLE'
   AND T1.TABLE_SCHEMA = 'baikal'
   AND T1.ENGINE = 'InnoDB'
   AND T1.ROW_FORMAT <> 'Compressed'
 ORDER BY T1.TABLE_NAME
__HEREDOC_2__
)

tables=$(mysql ${connection_string_no_db} \
 --skip-column-names \
 --database=information_schema \
 --execute="${sql}")

for table in ${tables[@]}; do
    mysql ${connection_string} \
     --execute="SET GLOBAL innodb_file_per_table=1;SET GLOBAL innodb_file_format=Barracuda;"
    break
done

for table in ${tables[@]}; do
    for size in 1 2 4 8 16; do
        mysql ${connection_string} \
         --execute="ALTER TABLE ${table} ENGINE=InnoDB ROW_FORMAT=compressed KEY_BLOCK_SIZE=${size};"
        if [ $? -eq 0 ]; then
            echo "${table} KEY_BLOCK_SIZE=${size}"
            break
        fi
    done
done

pushd ${OPENSHIFT_DATA_DIR}/scripts/ > /dev/null

for target_uri in carp saekics soccer tv
do
    ./ical_multi.sh $(cat ${OPENSHIFT_DATA_DIR}/params/schedule_server) ${target_uri}
done
./ical_multi.sh dummy holiday "http://ical.mac.com/ical/Japanese32Holidays.ics"
./ical_multi.sh dummy shinkan "http://sinkan.net/?action_ical=true&uid=12500&key=dd01838215ab8f727710f8e711d9fa47"
./ical_multi.sh dummy tenki "http://weather.livedoor.com/forecast/ical/34/90.ics"

popd > /dev/null
__HEREDOC__
chmod +x baikal.sh &
echo baikal.sh >> jobs.allow

# * icalendar *

cat << '__HEREDOC__' > icalendar.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/cal/calendars/ > /dev/null
rm -f shinkan.ics
wget "http://sinkan.net/?action_ical=true&uid=12500&key=dd01838215ab8f727710f8e711d9fa47" -O shinkan.ics
rm -f tenki.ics
wget "http://weather.livedoor.com/forecast/ical/34/90.ics" -O tenki.ics
rm -f holidays.ics
wget "http://ical.mac.com/ical/Japanese32Holidays.ics" -O holidays.ics
rm -f f1.ics
wget "https://www.f1calendar.com/download/f1-calendar_p1_p2_p3_q_gp.ics" -O f1.ics
rm -f carp.ics
wget https://$(cat ${OPENSHIFT_DATA_DIR}/params/schedule_server)/schedule/carp -O carp.ics
popd > /dev/null
__HEREDOC__
chmod +x icalendar.sh &
echo icalendar.sh >> jobs.allow

# * optimize table *

cat << '__HEREDOC__' > optimize_table.sh
#!/bin/bash
export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S

hour=$((10#$(date +%H)))
if [ ${hour} -ne 3 ]; then
    exit
fi

connection_string=$(cat << __HEREDOC_2__
--user=${OPENSHIFT_MYSQL_DB_USERNAME}
--password=${OPENSHIFT_MYSQL_DB_PASSWORD}
--host=${OPENSHIFT_MYSQL_DB_HOST}
--port=${OPENSHIFT_MYSQL_DB_PORT}
--database=mysql
--silent
--batch
__HEREDOC_2__
)

mysql ${connection_string} --execute="SET GLOBAL innodb_file_per_table=1;SET GLOBAL innodb_file_format=Barracuda;" 

sql=$(cat << '__HEREDOC_2__'
SELECT CONCAT(T1.TABLE_SCHEMA, '.', T1.TABLE_NAME, ',', T1.CREATE_OPTIONS)
  FROM information_schema.TABLES T1
 WHERE T1.TABLE_ROWS IS NOT NULL
   AND T1.TABLE_ROWS > 0
   AND T1.TABLE_SCHEMA NOT IN ('performance_schema', 'mysql')
   AND T1.DATA_FREE > 0
   AND T1.ENGINE = 'InnoDB'
 ORDER BY T1.DATA_FREE DESC
 LIMIT 0, 30
__HEREDOC_2__
)

tables=$(mysql ${connection_string} --execute="${sql}")
if [ ${#tables[*]} -gt 0 ]; then
    for table_option in ${tables[@]}
    do
        table=$(echo "${table_option}" | awk -F, '{print $1}')
        option="$(echo "${table_option}" | awk -F, '{print $2}')"
        echo "$(date +%Y/%m/%d" "%H:%M:%S) OPTIMIZE START ${table}"
        mysql ${connection_string} --execute="ALTER TABLE ${table} ENGINE=InnoDB ${option};" 
        echo "$(date +%Y/%m/%d" "%H:%M:%S) OPTIMIZE FINISH ${table}"
    done
fi
__HEREDOC__
chmod +x optimize_table.sh &
echo optimize_table.sh >> jobs.allow

# * carp_news *

cat << '__HEREDOC__' > carp_news.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S
php ${OPENSHIFT_DATA_DIR}/github/openshift/app01/rss/carp_news.php > ${OPENSHIFT_DATA_DIR}/apache/htdocs/carp_news.xml
__HEREDOC__
chmod +x carp_news.sh &
echo carp_news.sh >> jobs.allow

# * railf_jp_rss_atom_xml *

cat << '__HEREDOC__' > convert_railf_jp_rss_atom_xml.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S

cd /tmp
rm -f atom.xml
wget http://railf.jp/rss/atom.xml
sed -i -e "s|&mdash;|-|g" atom.xml
cp -f atom.xml ${OPENSHIFT_DATA_DIR}/apache/htdocs/railf_jp_rss_atom.xml
rm atom.xml
__HEREDOC__
chmod +x convert_railf_jp_rss_atom_xml.sh &
echo convert_railf_jp_rss_atom_xml.sh >> jobs.allow

popd > /dev/null

# *** minutely ***

echo "$(date +%Y/%m/%d" "%H:%M:%S) cron minutely" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null
rm -f ./*
touch jobs.deny

cat << '__HEREDOC__' > minutely_jobs.sh
#!/bin/bash

export TZ=JST-9
date +%Y/%m/%d" "%H:%M:%S
hour=$((10#$(date +%H)))
weekday=$(date +%w)
url="$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy"

pushd ${OPENSHIFT_DATA_DIR}/scripts > /dev/null

for shell_name in redmine_repository_check update_feeds
do
    if [ ${hour} -ne 1 ]; then
        # function030 "cron=minutely&shell_name=${shell_name}"
        touch ${OPENSHIFT_LOG_DIR}/${shell_name}.sh.log.${weekday}
        ./${shell_name}.sh >> ${OPENSHIFT_LOG_DIR}/${shell_name}.sh.log.${weekday} 2>&1
        ln -s -f ${OPENSHIFT_LOG_DIR}/${shell_name}.sh.log.${weekday} ${OPENSHIFT_LOG_DIR}/${shell_name}.sh.log
    fi
done

for shell_name in beacon memcached_status mrtg passenger_status process_status keep_process
do
    # function030 "cron=minutely&shell_name=${shell_name}"
    touch ${OPENSHIFT_LOG_DIR}/${shell_name}.sh.log.${weekday}
    ./${shell_name}.sh >>${OPENSHIFT_LOG_DIR}/${shell_name}.sh.log.${weekday} 2>&1
    ln -s -f ${OPENSHIFT_LOG_DIR}/${shell_name}.sh.log.${weekday} ${OPENSHIFT_LOG_DIR}/${shell_name}.sh.log
done

# ./cacti_poller.sh >>${OPENSHIFT_LOG_DIR}/cacti_poller.sh.log 2>&1 &
# ./my_server_check.sh >>${OPENSHIFT_LOG_DIR}/my_server_check.sh.log 2>&1 &

popd > /dev/null
__HEREDOC__
chmod +x minutely_jobs.sh &
echo minutely_jobs.sh >> jobs.allow

wait

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
