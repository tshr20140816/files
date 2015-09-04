#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** sphinx *****

# https://blog.openshift.com/easy-full-text-search-with-sphinx/

rm -f ${OPENSHIFT_TMP_DIR}/sphinx-${sphinx_version}-release.tar.xz
rm -f ${OPENSHIFT_TMP_DIR}/${OPENSHIFT_APP_UUID}_maked_sphinx-${sphinx_version}.tar.xz
rm -rf ${OPENSHIFT_TMP_DIR}/sphinx-${sphinx_version}
rm -rf ${OPENSHIFT_DATA_DIR}/sphinx

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    file_name=${OPENSHIFT_APP_UUID}_maked_sphinx-${sphinx_version}.tar.xz
    url=$(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    while :
    do
        if [ $(wget -nv --spider --timeout 60 -t 1 ${url} 2>&1 | grep -c '200 OK') -eq 1 ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx maked wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            break
        else
            echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx maked waiting" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            sleep 10s
        fi
    done
    wget $(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx maked tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar Jxf ${file_name}
    rm -f ${file_name}
else
    cp -f ${OPENSHIFT_DATA_DIR}/download_files/sphinx-${sphinx_version}-release.tar.xz ./
    echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar jxf sphinx-${sphinx_version}-release.tar.xz
fi
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/sphinx-${sphinx_version} > /dev/null

# *** configure make install ***

if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    export CC="ccache gcc"
    export CXX="ccache g++"
else
    echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_sphinx.log
    ./configure \
     --prefix=${OPENSHIFT_DATA_DIR}/sphinx \
     --mandir=/tmp/gomi \
     --infodir=/tmp/gomi \
     --docdir=/tmp/gomi \
     --disable-dependency-tracking \
     --disable-id64 \
     --with-mysql \
     --without-syslog 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_sphinx.log
    echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_sphinx.log
    time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_sphinx.log
fi

echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_sphinx.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_sphinx.log
mv ${OPENSHIFT_LOG_DIR}/install_sphinx.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

unset CC
unset CXX

# *** config ***

# ★

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -f sphinx-${sphinx_version}-release.tar.xz
rm -rf sphinx-${sphinx_version}
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
