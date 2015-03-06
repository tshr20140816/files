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
cat lscpu | tee -a infrastructure.txt
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
echo $(date +%Y/%m/%d" "%H:%M:%S) start >> ${OPENSHIFT_LOG_DIR}/start.log
rm -f ${OPENSHIFT_TMP_DIR}/redmine_repository_check.txt
rm -f ${OPENSHIFT_DATA_DIR}/mrtg/mrtg.conf_l
${OPENSHIFT_DATA_DIR}/apache/bin/apachectl -k graceful
${OPENSHIFT_DATA_DIR}/scripts/logrotate_zantei.sh &
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
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo $(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename $0) | tee -a ${OPENSHIFT_LOG_DIR}/install.log
