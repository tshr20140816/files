#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

processor_count=$(grep -c -e processor /proc/cpuinfo)
cpu_clock=$(grep -e MHz /proc/cpuinfo | head -n1 | awk -F'[ .]' '{print $3}')
model_name=$(grep -e "model name" /proc/cpuinfo | head -n1 \
 | awk '{print $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14}' \
 | sed -e 's/[ \t]*$//' | sed -e 's/ /_/g')
query_string="server=${OPENSHIFT_GEAR_DNS}&pc=${processor_count}&clock=${cpu_clock}&model=${model_name}&uuid=${USER}"
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

# ***** openssh *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/openssh-${openssh_version}.tar.gz ./
tar zxf openssh-${openssh_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/openssh-${openssh_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) openssh configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_openssh.log
# ./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/openssh \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 | tee -a ${OPENSHIFT_LOG_DIR}/install_openssh.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) openssh make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_openssh.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_openssh.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) openssh make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_openssh.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_openssh.log
mv ${OPENSHIFT_LOG_DIR}/install_openssh.log ${OPENSHIFT_LOG_DIR}/install/
rm ${OPENSHIFT_TMP_DIR}/openssh-${openssh_version}.tar.gz
rm -rf ${OPENSHIFT_TMP_DIR}/openssh-${openssh_version}
# export PATH="${OPENSHIFT_DATA_DIR}/openssh/bin:$PATH"
cat << __HEREDOC__ >> ${OPENSHIFT_DATA_DIR}/openssh/etc/ssh_config

IdentityFile ${OPENSHIFT_DATA_DIR}.ssh/id_rsa
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
LogLevel QUIET
__HEREDOC__
popd > /dev/null

# ***** ccache *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/ccache-${ccache_version}.tar.xz ./
tar Jxf ccache-${ccache_version}.tar.xz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/ccache-${ccache_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) ccache configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_ccache.log
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/ccache \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 | tee -a ${OPENSHIFT_LOG_DIR}/install_ccache.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) ccache make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_ccache.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_ccache.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) ccache make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_ccache.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_ccache.log
popd > /dev/null
mv ${OPENSHIFT_LOG_DIR}/install_ccache.log ${OPENSHIFT_LOG_DIR}/install/
rm ${OPENSHIFT_TMP_DIR}/ccache-${ccache_version}.tar.xz
rm -rf ${OPENSHIFT_TMP_DIR}/ccache-${ccache_version}

mkdir ${OPENSHIFT_TMP_DIR}/ccache
mkdir ${OPENSHIFT_TMP_DIR}/tmp_ccache

export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_MAXSIZE=300M
# export CC="ccache gcc"
# export CXX="ccache g++"

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
# ccache -z
# ccache -s | tee -a ${OPENSHIFT_LOG_DIR}/install.log

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename "${0}").ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
