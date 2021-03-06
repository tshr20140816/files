#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** start *****

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null

# * for_restart *

cat << '__HEREDOC__' > for_restart.sh
#!/bin/bash

export LOGSHIFTER_DIY_MAX_FILESIZE=5M

testrubyserver_count=$(ps aux | grep -e testrubyserver.rb | grep -e ${OPENSHIFT_APP_UUID} | grep -c -v grep)

[ ${testrubyserver_count} -gt 0 ] || exit

# *** kill testrubyserver.rb ***
kill $(ps auwx 2>/dev/null | grep -e testrubyserver.rb | grep -e ${OPENSHIFT_APP_UUID} | grep -v grep | awk '{print $2}')

# *** apache ***
export TZ=JST-9
${OPENSHIFT_DATA_DIR}/apache/bin/apachectl -k graceful

# *** delegate ***
pushd ${OPENSHIFT_DATA_DIR}/delegate
./delegated -r +=P30080
./delegated -r +=P33128
popd > /dev/null

# *** memcached ***
${OPENSHIFT_DATA_DIR}/memcached/bin/memcached -l ${OPENSHIFT_DIY_IP} \
 -p 31211 -U 0 -m 60 -C -d &>> ${OPENSHIFT_LOG_DIR}/memcached.log
__HEREDOC__
chmod +x for_restart.sh
./for_restart.sh
echo for_restart.sh >> jobs.allow
popd > /dev/null

# *** webalizer first process ***

wget --spider https://${OPENSHIFT_APP_DNS}/
wget --spider https://${OPENSHIFT_APP_DNS}/redmine/
sleep 5s

${OPENSHIFT_REPO_DIR}/.openshift/cron/hourly/webalizer.sh

# *** passenger status ***

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
[ $(echo $PATH | grep -c ${OPENSHIFT_DATA_DIR}/.rbenv/bin) -eq 0 ] && export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
[ $(echo $PATH | grep -c ${OPENSHIFT_DATA_DIR}/.gem/bin) -eq 0 ] && export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"
rbenv global ${ruby_version}
rbenv rehash

ruby --version
# export PASSENGER_TEMP_DIR=${OPENSHIFT_DATA_DIR}/tmp
# too long unix socket path (max: 107bytes)
# export PASSENGER_TEMP_DIR=${OPENSHIFT_TMP_DIR}/PassengerTempDir
# find ${OPENSHIFT_DATA_DIR}/.gem/gems/ -name passenger-status -type f | xargs -i ruby {} --verbose
${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-status --verbose

# ***** restart *****

echo "restart" > ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt
sleep 30s
while :
do
    [ -f ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt ] && sleep 10s || break
done

set +x

echo "https://${OPENSHIFT_APP_DNS}/wordpress/"
echo "https://${OPENSHIFT_APP_DNS}/ttrss/ admin/password"
echo "https://${OPENSHIFT_APP_DNS}/mail/"
echo "https://${OPENSHIFT_APP_DNS}/webalizer/"
echo "https://${OPENSHIFT_APP_DNS}/mrtg/"
echo "https://${OPENSHIFT_APP_DNS}/redmine/ admin/admin"
echo "https://${OPENSHIFT_APP_DNS}/cacti/ admin/admin"
echo "https://${OPENSHIFT_APP_DNS}/baikal/ admin/--"
echo "https://${OPENSHIFT_APP_DNS}/info/ user/${OPENSHIFT_APP_NAME}"
echo "https://${OPENSHIFT_APP_DNS}/logs/ user/${OPENSHIFT_APP_NAME}"

echo "Do not git push"

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename "${0}").ok
touch ${OPENSHIFT_DATA_DIR}/install_check_point/install_all.ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
