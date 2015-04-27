#!/bin/bash

source functions.sh
function010 stop
[ $? -eq 0 ] || exit

# ***** Tcl *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    file_name=${OPENSHIFT_APP_UUID}_maked_tcl${tcl_version}-src.tar.xz
    url=$(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    while :
    do
        if [ $(wget -nv --spider --timeout 60 -t 1 ${url} 2>&1 | grep -c '200 OK') -eq 1 ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) apache maked wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            break
        else
            echo "$(date +%Y/%m/%d" "%H:%M:%S) apache maked waiting" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            sleep 10s
        fi
    done
    wget $(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    echo "$(date +%Y/%m/%d" "%H:%M:%S) apache maked tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar Jxf ${file_name}
    rm -f ${file_name}
else
    cp ${OPENSHIFT_DATA_DIR}/download_files/tcl${tcl_version}-src.tar.gz ./

    echo "$(date +%Y/%m/%d" "%H:%M:%S) Tcl tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar xfz tcl${tcl_version}-src.tar.gz
fi
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/tcl${tcl_version}/unix > /dev/null
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    export CC="ccache gcc"
    export CXX="ccache g++"
else
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Tcl configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_tcl.log
    ./configure \
     --mandir=${OPENSHIFT_TMP_DIR}/man \
     --disable-symbols \
     --prefix=${OPENSHIFT_DATA_DIR}/tcl 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_tcl.log

    echo "$(date +%Y/%m/%d" "%H:%M:%S) Tcl make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_tcl.log
    # j2 is limit (-l3 --load-average=3)
    time make -j2 -l3 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_tcl.log
fi

echo "$(date +%Y/%m/%d" "%H:%M:%S) Tcl make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_tcl.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_tcl.log
mv ${OPENSHIFT_LOG_DIR}/install_tcl.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null
unset CC
unset CXX

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm tcl${tcl_version}-src.tar.gz
# TODO
# rm -rf tcl${tcl_version}
popd > /dev/null

oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}' \
 | tee -a ${OPENSHIFT_LOG_DIR}/install.log

query_string="server=${OPENSHIFT_GEAR_DNS}&installed=tcl"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

# ***** Expect *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/expect${expect_version}.tar.gz ./

echo "$(date +%Y/%m/%d" "%H:%M:%S) Expect tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar xfz expect${expect_version}.tar.gz
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/expect${expect_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) Expect configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_expect.log
 ./configure \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --prefix=${OPENSHIFT_DATA_DIR}/expect 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_expect.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) Expect make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_expect.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_expect.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) Expect make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_expect.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_expect.log
mv ${OPENSHIFT_LOG_DIR}/install_expect.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm expect${expect_version}.tar.gz
rm -rf expect${expect_version}
popd > /dev/null

query_string="server=${OPENSHIFT_GEAR_DNS}&installed=expect"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

# ***** rhc *****

# *** env ***

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
eval "$(rbenv init -)"
rbenv global ${ruby_version}
rbenv rehash

# *** install ***

echo "$(date +%Y/%m/%d" "%H:%M:%S) rhc install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

time rbenv exec gem install rhc --no-rdoc --no-ri --verbose \
 -V -- --with-cflags=\"-O2 -pipe -march=native -fomit-frame-pointer -s\" > ${OPENSHIFT_LOG_DIR}/rhc.gem.log 2>&1
rbenv rehash
mv ${OPENSHIFT_LOG_DIR}/rhc.gem.log ${OPENSHIFT_LOG_DIR}/install/

rm -f ${OPENSHIFT_TMP_DIR}/rhc.stderr.log
touch ${OPENSHIFT_TMP_DIR}/rhc.stderr.log
rhc_version_info=$(rhc --version 2> ${OPENSHIFT_TMP_DIR}/rhc.stderr.log | grep -e rhc)
echo "$(date +%Y/%m/%d" "%H:%M:%S) ${rhc_version_info}" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
if [ $(grep -c -e 'command not found' ${OPENSHIFT_TMP_DIR}/rhc.stderr.log) -gt 0 ]; then
    query_string="server=${OPENSHIFT_GEAR_DNS}&error=rhc"
    wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" \
     > /dev/null 2>&1
fi
rm -f ${OPENSHIFT_TMP_DIR}/rhc.stderr.log

query_string="server=${OPENSHIFT_GEAR_DNS}&installed=rhc"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

# *** setup ***

echo "$(date +%Y/%m/%d" "%H:%M:%S) rhc setup" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

openshift_email_address=$(cat ${OPENSHIFT_DATA_DIR}/params/openshift_email_address)
openshift_email_password=$(cat ${OPENSHIFT_DATA_DIR}/params/openshift_email_password)

echo set timeout 60 > ${OPENSHIFT_TMP_DIR}/rhc_setup.txt
echo spawn ${OPENSHIFT_DATA_DIR}.gem/bin/rhc setup --server openshift.redhat.com \
--create-token -l ${openshift_email_address} -p ${openshift_email_password} >> ${OPENSHIFT_TMP_DIR}/rhc_setup.txt
cat << '__HEREDOC__' >> ${OPENSHIFT_TMP_DIR}/rhc_setup.txt
expect "(yes|no)"
send "yes\r"
expect "(yes|no)"
send "yes\r"
expect "Provide a name for this key"
send "\r"
interact
__HEREDOC__

env_home_backup=${HOME}
export HOME=${OPENSHIFT_DATA_DIR}
${OPENSHIFT_DATA_DIR}/tcl/bin/expect -f ${OPENSHIFT_TMP_DIR}/rhc_setup.txt >${OPENSHIFT_LOG_DIR}/rhc.setup.log 2>&1
mv ${OPENSHIFT_LOG_DIR}/rhc.setup.log ${OPENSHIFT_LOG_DIR}/install/

${OPENSHIFT_DATA_DIR}.gem/bin/rhc apps
${OPENSHIFT_DATA_DIR}.gem/bin/rhc apps | grep uuid | tee -a ${OPENSHIFT_LOG_DIR}/install.log
export HOME=${env_home_backup}

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
