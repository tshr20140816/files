#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** jpegoptim *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/jpegoptim-${jpegoptim_version}.tar.gz ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) jpegoptim tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar zxf jpegoptim-${jpegoptim_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/jpegoptim-${jpegoptim_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) jpegoptim configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_jpegoptim.log
./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/jpegoptim \
 --mandir=${OPENSHIFT_TMP_DIR}/man 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_jpegoptim.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) jpegoptim make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_jpegoptim.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_jpegoptim.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) jpegoptim make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_jpegoptim.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_jpegoptim.log
popd > /dev/null
mv ${OPENSHIFT_LOG_DIR}/install_jpegoptim.log ${OPENSHIFT_LOG_DIR}/install/
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm jpegoptim-${jpegoptim_version}.tar.gz
rm -rf jpegoptim-${jpegoptim}
popd > /dev/null

# ***** optipng *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/optipng-${optipng_version}.tar.gz ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) optipng tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar zxf optipng-${optipng_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/optipng-${optipng_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) optipng configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_optipng.log
./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/optipng \
 --mandir=${OPENSHIFT_TMP_DIR}/man 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_optipng.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) optipng make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_optipng.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_optipng.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) optipng make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_optipng.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_optipng.log
popd > /dev/null
mv ${OPENSHIFT_LOG_DIR}/install_optipng.log ${OPENSHIFT_LOG_DIR}/install/
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm optipng-${optipng_version}.tar.gz
rm -rf optipng-${optipng}
popd > /dev/null

# ***** curl *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/curl-${curl_version}.tar.bz2 ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) curl tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar jxf curl-${curl_version}.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/curl-${curl_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) curl configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_curl.log
./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/curl \
 --mandir=${OPENSHIFT_TMP_DIR}/man 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_curl.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) curl make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_curl.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_curl.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) curl make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_curl.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_curl.log
popd > /dev/null
mv ${OPENSHIFT_LOG_DIR}/install_curl.log ${OPENSHIFT_LOG_DIR}/install/
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm curl-${curl_version}.tar.bz2
rm -rf curl-${curl_version}
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/curl/bin > /dev/null
file curl | tee -a ${OPENSHIFT_LOG_DIR}/install_curl.log
strip --strip-all curl | tee -a ${OPENSHIFT_LOG_DIR}/install_curl.log
file curl | tee -a ${OPENSHIFT_LOG_DIR}/install_curl.log
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename "${0}").ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
