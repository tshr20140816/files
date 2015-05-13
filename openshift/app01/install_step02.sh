#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

processor_count=$(grep -c -e processor /proc/cpuinfo)
cpu_clock=$(grep -e MHz /proc/cpuinfo | head -n1 | awk -F'[ .]' '{print $3}')
model_name=$(grep -e "model name" /proc/cpuinfo | head -n1 \
 | awk '{print $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14}' \
 | sed -e 's/[ \t]*$//' | sed -e 's/ /_/g')
query_string="server=${OPENSHIFT_APP_DNS}&pc=${processor_count}&clock=${cpu_clock}&model=${model_name}&uuid=${USER}"
wget --spider $(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string} > /dev/null 2>&1

# ***** make directories *****

mkdir ${OPENSHIFT_DATA_DIR}/tmp
mkdir ${OPENSHIFT_DATA_DIR}/etc
mkdir -p ${OPENSHIFT_DATA_DIR}/var/www/cgi-bin
mkdir ${OPENSHIFT_DATA_DIR}/bin
mkdir ${OPENSHIFT_DATA_DIR}/scripts
mkdir ${OPENSHIFT_TMP_DIR}/man
mkdir ${OPENSHIFT_TMP_DIR}/doc

# ***** bash_profile *****

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
touch .bash_profile
cat << '__HEREDOC__' >> .bash_profile

export TMOUT=0
export TZ=JST-9
alias ls='ls -lang --color=auto'
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
__HEREDOC__
popd > /dev/null

# ***** vim *****

echo set number >> ${OPENSHIFT_DATA_DIR}/.vimrc

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename "${0}").ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
