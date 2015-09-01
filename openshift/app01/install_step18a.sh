#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** squid *****

rm -f ${OPENSHIFT_TMP_DIR}/squid-${squid_version}.tar.xz
rm -f ${OPENSHIFT_TMP_DIR}/${OPENSHIFT_APP_UUID}_maked_squid-${squid_version}.tar.xz
rm -rf ${OPENSHIFT_TMP_DIR}/squid-${squid_version}
rm -rf ${OPENSHIFT_DATA_DIR}/squid

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    file_name=${OPENSHIFT_APP_UUID}_maked_squid-${squid_version}.tar.xz
    url=$(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    while :
    do
        if [ $(wget -nv --spider --timeout 60 -t 1 ${url} 2>&1 | grep -c '200 OK') -eq 1 ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) squid maked wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            break
        else
            echo "$(date +%Y/%m/%d" "%H:%M:%S) squid maked waiting" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            sleep 10s
        fi
    done
    wget $(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    echo "$(date +%Y/%m/%d" "%H:%M:%S) squid maked tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar Jxf ${file_name}
    rm -f ${file_name}
else
    cp -f ${OPENSHIFT_DATA_DIR}/download_files/httpd-${apache_version}.tar.bz2 ./
    echo "$(date +%Y/%m/%d" "%H:%M:%S) squid tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar jxf squid-${squid_version}.tar.bz2
fi
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/squid-${squid_version} > /dev/null

# *** configure make install ***

if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    export CC="ccache gcc"
    export CXX="ccache g++"
else
    echo "$(date +%Y/%m/%d" "%H:%M:%S) squid configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_squid.log
    ./configure \
     --prefix=${OPENSHIFT_DATA_DIR}/squid \
     --mandir=/tmp/gomi \
     --infodir=/tmp/gomi \
     --docdir=/tmp/gomi \
     --disable-dependency-tracking \
     --enable-shared \
     --enable-static=no \
     --enable-fast-install \
     --disable-icap-client \
     --disable-wccp \
     --disable-wccpv2 \
     --disable-snmp \
     --disable-eui \
     --disable-htcp \
     --disable-devpoll \
     --disable-ipv6 \
     --disable-auto-locale 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_squid.log
    echo "$(date +%Y/%m/%d" "%H:%M:%S) apache make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_squid.log
    time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_squid.log
fi

echo "$(date +%Y/%m/%d" "%H:%M:%S) squid make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_squid.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_squid.log
mv ${OPENSHIFT_LOG_DIR}/install_squid.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

unset CC
unset CXX
