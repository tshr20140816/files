#!/bin/bash

source functions.sh
function010 restart
[ $? -eq 0 ] || exit

apcu_version="4.0.10"

# *** apcu ***

rm -f ${OPENSHIFT_TMP_DIR}/apcu-${apcu_version}.zip
rm -rf apcu-${apcu_version}

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -O apcu-${apcu_version}.zip https://github.com/krakjoe/apcu/archive/${apcu_version}.zip
echo "$(date +%Y/%m/%d" "%H:%M:%S) apcu unzip" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
unzip apcu-${apcu_version}.zip
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/apcu-${apcu_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) apcu phpize" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
${OPENSHIFT_DATA_DIR}/php/bin/phpize
echo "$(date +%Y/%m/%d" "%H:%M:%S) apcu configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_apcu.log
./configure \
 --with-php-config=${OPENSHIFT_DATA_DIR}/php/bin/php-config
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --prefix=${OPENSHIFT_DATA_DIR}/apcu 2>&1 \
 | tee -a ${OPENSHIFT_LOG_DIR}/install_apcu.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) apcu make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_apcu.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_apcu.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) apcu make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_apcu.log
time make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_apcu.log
mv ${OPENSHIFT_LOG_DIR}/install_apcu.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm apcu-${apcu_version}.zip
rm -rf apcu-${apcu_version}
popd > /dev/null

query_string="server=${OPENSHIFT_APP_DNS}&installed=apcu"
wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

# php.ini
# extension=apcu.so
# apc.enabled=1
# apc.shm_size=32M
# apc.ttl=7200
# apc.enable_cli=1

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
