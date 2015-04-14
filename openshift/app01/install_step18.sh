#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** register url *****

curl --digest -u $(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server_user):$(date +%Y%m%d%H) \
 -F "url=https://${OPENSHIFT_GEAR_DNS}/" \
$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)createwebcroninformation

# ***** infrastructure info *****

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/ > /dev/null

echo "\$ hostname" > infrastructure.txt
hostname | tee -a infrastructure.txt
echo >> infrastructure.txt
echo "\$ uname -a" >> infrastructure.txt
uname -a | tee -a infrastructure.txt
echo >> infrastructure.txt
echo "\$ cat /proc/version" >> infrastructure.txt
cat /proc/version | tee -a infrastructure.txt
echo >> infrastructure.txt
echo "\$ cat /etc/redhat-release" >> infrastructure.txt
cat /etc/redhat-release | tee -a infrastructure.txt
echo >> infrastructure.txt
echo "\$ lscpu" >> infrastructure.txt
lscpu | tee -a infrastructure.txt
echo >> infrastructure.txt
echo "\$ cat /proc/cpuinfo" >> infrastructure.txt
cat /proc/cpuinfo | tee -a infrastructure.txt
echo >> infrastructure.txt
echo "\$ ulimit -a" >> infrastructure.txt
ulimit -a | tee -a infrastructure.txt
echo >> infrastructure.txt
echo "\$ cat /etc/inittab | grep -v ^#" >> infrastructure.txt
cat /etc/inittab | grep -v ^# | tee -a infrastructure.txt
echo >> infrastructure.txt
echo "\$ cat /etc/resolv.conf" >> infrastructure.txt
cat /etc/resolv.conf | tee -a infrastructure.txt
echo >> infrastructure.txt
echo "\$ mysql --help" >> infrastructure.txt
mysql --help | tee -a infrastructure.txt

popd > /dev/null

# ***** action hooks *****

pushd ${OPENSHIFT_REPO_DIR}/.openshift/action_hooks > /dev/null
cp start start.org
cat << '__HEREDOC__' > start
#!/bin/bash

export TZ=JST-9
echo "$(date +%Y/%m/%d" "%H:%M:%S) start" >> ${OPENSHIFT_LOG_DIR}/start.log
rm -f ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt
rm -f ${OPENSHIFT_DATA_DIR}/mrtg/mrtg.conf_l
cp -f $OPENSHIFT_MYSQL_DIR/conf/my.cnf ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/

sqls=()
sqls=("${sqls[@]}" "SET GLOBAL default_storage_engine=InnoDB;")
sqls=("${sqls[@]}" "SET GLOBAL time_zone='+9:00';")
sqls=("${sqls[@]}" "SET GLOBAL innodb_file_per_table=1;")
sqls=("${sqls[@]}" "SET GLOBAL innodb_file_format=Barracuda;")

for (( i = 0; i < ${#sqls[@]}; i++ )); do

    mysql --user="${OPENSHIFT_MYSQL_DB_USERNAME}" \
     --password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
     --host="${OPENSHIFT_MYSQL_DB_HOST}" \
     --port="${OPENSHIFT_MYSQL_DB_PORT}" \
     --silent \
     --batch \
     --execute="${sqls[$i]}" >> ${OPENSHIFT_LOG_DIR}/start.log 2>&1

done

mysql --user="${OPENSHIFT_MYSQL_DB_USERNAME}" \
 --password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
 --host="${OPENSHIFT_MYSQL_DB_HOST}" \
 --port="${OPENSHIFT_MYSQL_DB_PORT}" \
 --html \
 --execute="SHOW GLOBAL VARIABLES" \
 > ${OPENSHIFT_DATA_DIR}/apache/htdocs/info/mysql_global_variables.html

# *** apache ***
${OPENSHIFT_DATA_DIR}/apache/bin/apachectl -k graceful \
 >> ${OPENSHIFT_LOG_DIR}/start.log 2>&1

# *** delegate ***
pushd ${OPENSHIFT_DATA_DIR}/delegate
./delegated -r +=P30080 \
 >> ${OPENSHIFT_LOG_DIR}/start.log 2>&1
popd > /dev/null

# *** memcached ***
${OPENSHIFT_DATA_DIR}/memcached/bin/memcached -l ${OPENSHIFT_DIY_IP} \
 -p 31211 -U 0 -m 60 -C -d &>> ${OPENSHIFT_LOG_DIR}/memcached.log 2>&1

# if [ $(ps auwx 2>/dev/null | grep logrotate_zantei.sh | grep ${OPENSHIFT_DIY_IP} | grep -c -v grep) -gt 0 ]; then
#     kill $(ps auwx 2>/dev/null | grep logrotate_zantei.sh | grep ${OPENSHIFT_DIY_IP} | grep -v grep | awk '{print $2}')
# fi
# ${OPENSHIFT_DATA_DIR}/scripts/logrotate_zantei.sh ${OPENSHIFT_DIY_IP} &
echo "$(date +%Y/%m/%d" "%H:%M:%S) finish" >> ${OPENSHIFT_LOG_DIR}/start.log
__HEREDOC__
popd > /dev/null

# ***** log link *****

pushd ${OPENSHIFT_LOG_DIR} > /dev/null
touch ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/log/production.log
ln -s ${OPENSHIFT_DATA_DIR}/redmine-${redmine_version}/log/production.log production.log
touch ${OPENSHIFT_DATA_DIR}/apache/logs/access_log
ln -s ${OPENSHIFT_DATA_DIR}/apache/logs/access_log access_log
touch ${OPENSHIFT_DATA_DIR}/apache/logs/access_remoteip_log
ln -s ${OPENSHIFT_DATA_DIR}/apache/logs/access_remoteip_log access_remoteip_log
touch ${OPENSHIFT_DATA_DIR}/apache/logs/error_log
ln -s ${OPENSHIFT_DATA_DIR}/apache/logs/error_log error_log
touch ${OPENSHIFT_DATA_DIR}/apache/logs/rewrite_log
ln -s ${OPENSHIFT_DATA_DIR}/apache/logs/rewrite_log rewrite_log
touch ${OPENSHIFT_MYSQL_DIR}/stdout.err
ln -s ${OPENSHIFT_MYSQL_DIR}/stdout.err mysql_stdout_err.log

popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
