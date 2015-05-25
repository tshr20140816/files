#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** fio *****

rm -rf ${OPENSHIFT_TMP_DIR}/fio-${fio_version}
rm -rf ${OPENSHIFT_DATA_DIR}/fio

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/fio-${fio_version}.tar.bz2 ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) fio tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar jxf fio-${fio_version}.tar.bz2
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/fio-${fio_version} > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) fio configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_fio.log
./configure | tee -a ${OPENSHIFT_LOG_DIR}/install_fio.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) fio make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_fio.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_fio.log
sed -i -E "s|^prefix .+$|prefix = ${OPENSHIFT_DATA_DIR}fio|g" Makefile
echo "$(date +%Y/%m/%d" "%H:%M:%S) fio make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_fio.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_fio.log
mv ${OPENSHIFT_LOG_DIR}/install_fio.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

rm ${OPENSHIFT_TMP_DIR}/fio-${fio_version}.tar.bz2

# *** run fio ***

rm -rf ${OPENSHIFT_DATA_DIR}/work
pushd ${OPENSHIFT_DATA_DIR}fio > /dev/null
for rwtype in read write randread randwrite
do
    mkdir ${OPENSHIFT_DATA_DIR}/work

    ./bin/fio -rw=${rwtype} -bs=4k -size=10m -numjobs=10 -runtime=60 \
    -direct=1 -invalidate=1 \
    -iodepth=32 -iodepth_batch=32 -group_reporting -name=${rwtype} -directory=${OPENSHIFT_DATA_DIR}/work \
     | tee ${OPENSHIFT_LOG_DIR}/fio_${rwtype}.log

    aggrb=$(grep -e aggrb ${OPENSHIFT_LOG_DIR}/fio_${rwtype}.log | awk '{print $3}' | tr -d KB/s,)
    query_string="server=${OPENSHIFT_APP_DNS}&fio=${rwtype}&${aggrb}&uuid=${USER}"
    wget --spider $(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string} > /dev/null 2>&1

    mv ${OPENSHIFT_LOG_DIR}/fio_${rwtype}.log ${OPENSHIFT_LOG_DIR}/install/
    rm -rf ${OPENSHIFT_DATA_DIR}/work
done
popd > /dev/null

# TODO
# dbench
# UnixBench
# SysBench
# http://downloads.mysql.com/source/sysbench-0.4.12.5.tar.gz

# ***** super pi *****

rm -rf ${OPENSHIFT_TMP_DIR}/superpi
mkdir ${OPENSHIFT_TMP_DIR}/superpi
pushd ${OPENSHIFT_TMP_DIR}/superpi > /dev/null
wget ftp://pi.super-computing.org/Linux_jp/super_pi-jp.tar.gz
tar xfz super_pi-jp.tar.gz
./super_pi 20 | tee ${OPENSHIFT_LOG_DIR}/super_pi.log

sec=$(grep -e Total ${OPENSHIFT_LOG_DIR}/super_pi.log | awk '{print $4}' | tr -d \()
query_string="server=${OPENSHIFT_APP_DNS}&super_pi=${sec}s&uuid=${USER}"
wget --spider $(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string} > /dev/null 2>&1
mv ${OPENSHIFT_LOG_DIR}/super_pi.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null
rm -rf ${OPENSHIFT_TMP_DIR}/superpi

if [ 1 -eq 0 ]; then
# ***** GNU Parallel *****

rm -rf ${OPENSHIFT_TMP_DIR}/parallel-latest
rm -rf ${OPENSHIFT_DATA_DIR}/parallel
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/parallel-latest.tar.bz2 ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) GNU Parallel tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar jxf parallel-latest.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/parallel-* > /dev/null
echo "$(date +%Y/%m/%d" "%H:%M:%S) GNU Parallel configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_gnu_parallel.log
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/parallel \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_gnu_parallel.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) GNU Parallel make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_gnu_parallel.log
time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_gnu_parallel.log
echo "$(date +%Y/%m/%d" "%H:%M:%S) GNU Parallel make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_gnu_parallel.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_gnu_parallel.log
mv ${OPENSHIFT_LOG_DIR}/install_gnu_parallel.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null
rm ${OPENSHIFT_TMP_DIR}/parallel-latest.tar.bz2
${OPENSHIFT_DATA_DIR}/parallel/bin/parallel -v | tee -a ${OPENSHIFT_LOG_DIR}/install.log
fi

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename "${0}").ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
