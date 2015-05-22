#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** ssh *****

echo "$(date +%Y/%m/%d" "%H:%M:%S) ssh setup" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

mkdir ${OPENSHIFT_DATA_DIR}/.ssh
pushd ${OPENSHIFT_DATA_DIR}/.ssh > /dev/null
ssh -V
ssh-keygen -t rsa -f id_rsa -P ''
cat << '__HEREDOC__' > config
Host *
  IdentityFile __OPENSHIFT_DATA_DIR__.ssh/id_rsa
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel QUIET
#  LogLevel DEBUG3
  Protocol 2
  ConnectionAttempts 5
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" config
popd > /dev/null
mkdir ${OPENSHIFT_DATA_DIR}/bin
pushd ${OPENSHIFT_DATA_DIR}/bin > /dev/null
cat << '__HEREDOC__' > distcc-ssh
#!/bin/bash

echo "$(date +%Y/%m/%d" "%H:%M:%S) $@" >> ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
exec /usr/bin/ssh -F ${OPENSHIFT_DATA_DIR}/.ssh/config $@
__HEREDOC__
chmod +x distcc-ssh
popd > /dev/null

# ***** rhc *****
# ruby はデフォルトインストールのものに頼る

# *** env ***

distcc_server_account=$(cat ${OPENSHIFT_DATA_DIR}/params/distcc_server_account)
distcc_server_password=$(cat ${OPENSHIFT_DATA_DIR}/params/distcc_server_password)

env_home_backup=${HOME}
export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
export HOME=${OPENSHIFT_DATA_DIR}
gem --version
gem environment
gem help install

# *** install ***

echo "$(date +%Y/%m/%d" "%H:%M:%S) rhc install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# gem install commander -v 4.2.1 --verbose --no-rdoc --no-ri -- --with-cflags=\"-O2 -pipe -march=native -fomit-frame-pointer -s\"
gem install rhc --verbose --no-rdoc --no-ri -- --with-cflags=\"-O2 -pipe -march=native -fomit-frame-pointer -s\"

echo "$(date +%Y/%m/%d" "%H:%M:%S) rhc setup" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

yes | rhc setup --server openshift.redhat.com --create-token -l ${distcc_server_account} -p ${distcc_server_password}
pushd  ${OPENSHIFT_TMP_DIR} > /dev/null
rhc apps | grep -e SSH | grep -v -e ${OPENSHIFT_APP_UUID} | awk '{print $2}' | tee user_fqdn.txt
cat user_fqdn.txt | tee -a ${OPENSHIFT_LOG_DIR}/install.log
while read LINE
do
    user_fqdn=$(echo "${LINE}")
    ssh -24n -F ${OPENSHIFT_DATA_DIR}/.ssh/config ${user_fqdn} pwd 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    user_string=$(echo "${user_fqdn}" | awk -F@ '{print $1}')
    distcc_hosts_string="${user_fqdn}/2:/var/lib/openshift/${user_string}/app-root/data/distcc/bin/distccd_start "
    # distcc_hosts_string="${user_fqdn}/2:/var/lib/openshift/${user_string}/app-root/data/distcc/bin/distccd_start,lzo"
    echo -n "${distcc_hosts_string}" >> ${OPENSHIFT_DATA_DIR}/params/distcc_hosts.txt
done < user_fqdn.txt
# 後で使う
# rm -f user_fqdn.txt
popd > /dev/null
cat ${OPENSHIFT_DATA_DIR}/params/distcc_hosts.txt | tee -a ${OPENSHIFT_LOG_DIR}/install.log
export HOME=${env_home_backup}

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename "${0}").ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
