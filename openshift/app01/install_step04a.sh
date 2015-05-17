#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** Tcl *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    file_name=${OPENSHIFT_APP_UUID}_maked_tcl${tcl_version}.tar.xz
    url=$(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    while :
    do
        if [ $(wget -nv --spider --timeout 60 -t 1 ${url} 2>&1 | grep -c '200 OK') -eq 1 ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) Tcl maked wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            break
        else
            echo "$(date +%Y/%m/%d" "%H:%M:%S) Tcl maked waiting" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            sleep 10s
        fi
    done
    wget $(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Tcl maked tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
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

query_string="server=${OPENSHIFT_APP_DNS}&installed=tcl"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

# ***** Expect *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    file_name=${OPENSHIFT_APP_UUID}_maked_expect${expect_version}.tar.xz
    url=$(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    while :
    do
        if [ $(wget -nv --spider --timeout 60 -t 1 ${url} 2>&1 | grep -c '200 OK') -eq 1 ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) Expect maked wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            break
        else
            echo "$(date +%Y/%m/%d" "%H:%M:%S) Expect maked waiting" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            sleep 10s
        fi
    done
    wget $(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Expect maked tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar Jxf ${file_name}
    rm -f ${file_name}
else
    cp ${OPENSHIFT_DATA_DIR}/download_files/expect${expect_version}.tar.gz ./

    echo "$(date +%Y/%m/%d" "%H:%M:%S) Expect tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar xfz expect${expect_version}.tar.gz
fi
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/expect${expect_version} > /dev/null

# *** configure make install ***

if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    export CC="ccache gcc"
    export CXX="ccache g++"
else
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Expect configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_apache.log
    ./configure \
     --mandir=${OPENSHIFT_TMP_DIR}/man \
     --prefix=${OPENSHIFT_DATA_DIR}/expect 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_expect.log

    echo "$(date +%Y/%m/%d" "%H:%M:%S) Expect make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_expect.log
    time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_expect.log
fi

echo "$(date +%Y/%m/%d" "%H:%M:%S) Expect make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_expect.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_expect.log
mv ${OPENSHIFT_LOG_DIR}/install_expect.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm expect${expect_version}.tar.gz
rm -rf expect${expect_version}
popd > /dev/null

query_string="server=${OPENSHIFT_APP_DNS}&installed=expect"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

# ***** rhc *****

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
gem environment
gem help install
# gem install commander -v 4.2.1 --no-rdoc --no-ri --with-cflags=\"-O2 -pipe -march=native -fomit-frame-pointer -s\"
# gem install rhc --no-rdoc --no-ri --with-cflags=\"-O2 -pipe -march=native -fomit-frame-pointer -s\"
gem install commander -v 4.2.1 --no-rdoc --no-ri > ${OPENSHIFT_LOG_DIR}/commander.gem.log 2>&1
gem install rhc --no-rdoc --no-ri > ${OPENSHIFT_LOG_DIR}/rhc.gem.log 2>&1

# *** setup ***

echo "$(date +%Y/%m/%d" "%H:%M:%S) rhc setup" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

distcc_server_account=$(cat ${OPENSHIFT_DATA_DIR}/params/distcc_server_account)
distcc_server_password=$(cat ${OPENSHIFT_DATA_DIR}/params/distcc_server_password)

echo set timeout 60 > ${OPENSHIFT_TMP_DIR}/rhc_setup.txt
echo spawn ${OPENSHIFT_DATA_DIR}.gem/bin/rhc setup --server openshift.redhat.com \
--create-token -l ${distcc_server_account} -p ${distcc_server_password} >> ${OPENSHIFT_TMP_DIR}/rhc_setup.txt
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
${OPENSHIFT_DATA_DIR}/tcl/bin/expect -f ${OPENSHIFT_TMP_DIR}/rhc_setup.txt >${OPENSHIFT_LOG_DIR}/rhc.setup2.log 2>&1
mv ${OPENSHIFT_LOG_DIR}/rhc.setup2.log ${OPENSHIFT_LOG_DIR}/install/

pushd  ${OPENSHIFT_TMP_DIR} > /dev/null
rhc apps | grep -e SSH | grep -v -e ${OPENSHIFT_APP_UUID} | awk '{print $2}' > user_fqdn.txt
while read LINE
do
    user_fqdn=$(echo "${LINE}")
    ssh -V
    ssh -fMNv ${user_fqdn} 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    user_string=$(echo "${LINE}" | awk -F@ '{print $1}')
    distcc_hosts_string="${distcc_hosts_string} ${user_fqdn}/2:/var/lib/openshift/${user_string}/app-root/data/distcc/bin/distccd_start"
    # distcc_hosts_string="${distcc_hosts_string} ${user_fqdn}/2:/var/lib/openshift/${user_string}/app-root/data/distcc/bin/distccd_start,lzo"
done < user_fqdn.txt
rm -f user_fqdn.txt
popd > /dev/null
distcc_hosts_string="${distcc_hosts_string:1}"
echo "${distcc_hosts_string}" > ${OPENSHIFT_DATA_DIR}/params/distcc_hosts.txt
export HOME=${env_home_backup}

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename "${0}").ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
