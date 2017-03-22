#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** distcc *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
# cp -f ${OPENSHIFT_DATA_DIR}/download_files/distcc-${distcc_version}.tar.bz2 ./
# echo "$(date +%Y/%m/%d" "%H:%M:%S) distcc tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
# tar jxf distcc-${distcc_version}.tar.bz2
wget https://github.com/distcc/distcc/archive/distcc-3.1.zip
unzip distcc-3.1.zip
popd > /dev/null
# pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/distcc-distcc-3.1 > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) distcc configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_distcc.log
./autogen.sh
# ./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/distcc \
 --infodir=${OPENSHIFT_TMP_DIR}/gomi \
 --mandir=${OPENSHIFT_TMP_DIR}/gomi 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_distcc.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) distcc make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_distcc.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_distcc.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) distcc make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_distcc.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_distcc.log
popd > /dev/null
mv ${OPENSHIFT_LOG_DIR}/install_distcc.log ${OPENSHIFT_LOG_DIR}/install/
# rm ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version}.tar.bz2
# rm -rf distcc-${distcc_version}
rm -f distcc-3.1.zip
rm -rf distcc-distcc-3.1

mkdir ${OPENSHIFT_DATA_DIR}/.distcc

# [ $(echo $PATH | grep -c ${OPENSHIFT_DATA_DIR}/distcc/bin) -eq 0 ] && export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
# export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
# export DISTCC_LOG=/dev/null

# ***** ccache *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/ccache-${ccache_version}.tar.xz ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) ccache tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar Jxf ccache-${ccache_version}.tar.xz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/ccache-${ccache_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) ccache configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_ccache.log
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/ccache \
 --mandir=${OPENSHIFT_TMP_DIR}/gomi \
 --docdir=${OPENSHIFT_TMP_DIR}/gomi 2>&1 \
 | tee -a ${OPENSHIFT_LOG_DIR}/install_ccache.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) ccache make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_ccache.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_ccache.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) ccache make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_ccache.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_ccache.log
popd > /dev/null
strip ${OPENSHIFT_DATA_DIR}/ccache/bin/ccache
mv ${OPENSHIFT_LOG_DIR}/install_ccache.log ${OPENSHIFT_LOG_DIR}/install/
rm ${OPENSHIFT_TMP_DIR}/ccache-${ccache_version}.tar.xz
rm -rf ${OPENSHIFT_TMP_DIR}/ccache-${ccache_version}

mkdir ${OPENSHIFT_TMP_DIR}/ccache
mkdir ${OPENSHIFT_TMP_DIR}/tmp_ccache

# export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
# export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
# #export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
# export CCACHE_LOGFILE=/dev/null
# export CCACHE_MAXSIZE=300M
# # export CC="ccache gcc"
# # export CXX="ccache g++"

# [ $(echo $PATH | grep -c ${OPENSHIFT_DATA_DIR}/ccache/bin) -eq 0 ] && export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
# ccache -z
# ccache -s | tee -a ${OPENSHIFT_LOG_DIR}/install.log

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename "${0}").ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
