#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** cadaver *****

rm -f ${OPENSHIFT_TMP_DIR}/cadaver-${cadaver_version}.tar.gz
rm -f ${OPENSHIFT_TMP_DIR}/${OPENSHIFT_APP_UUID}_maked_cadaver-${cadaver_version}.tar.xz
rm -rf ${OPENSHIFT_TMP_DIR}/cadaver-${cadaver_version}
rm -rf ${OPENSHIFT_DATA_DIR}/cadaver

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    file_name=${OPENSHIFT_APP_UUID}_maked_cadaver-${cadaver_version}.tar.xz
    url=$(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    while :
    do
        if [ $(wget -nv --spider --timeout 60 -t 1 ${url} 2>&1 | grep -c '200 OK') -eq 1 ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver maked wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            break
        else
            echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver maked waiting" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            sleep 10s
        fi
    done
    wget $(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver maked tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar Jxf ${file_name}
    rm -f ${file_name}
else
    cp ${OPENSHIFT_DATA_DIR}/download_files/cadaver-${cadaver_version}.tar.gz ./
    echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar zxf cadaver-${cadaver_version}.tar.gz
fi
popd > /dev/null

# *** configure make install ***

pushd ${OPENSHIFT_TMP_DIR}/cadaver-${cadaver_version} > /dev/null

if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    export CC="ccache gcc"
    export CXX="ccache g++"
else
    echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_cadaver.log

    ./configure \
     --mandir=${OPENSHIFT_TMP_DIR}/man \
     --docdir=${OPENSHIFT_TMP_DIR}/doc \
     --with-ssl=openssl \
     --prefix=${OPENSHIFT_DATA_DIR}/cadaver 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_cadaver.log

    echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_cadaver.log

    time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_cadaver.log
fi

echo "$(date +%Y/%m/%d" "%H:%M:%S) cadaver make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_cadaver.log

make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_cadaver.log
mv ${OPENSHIFT_LOG_DIR}/install_cadaver.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

rm -f ${OPENSHIFT_TMP_DIR}/cadaver-${cadaver_version}.tar.gz
rm -rf ${OPENSHIFT_TMP_DIR}/cadaver-${cadaver_version}

# *** setup ***

# * .netrc *
# for automatic login

hidrive_account=$(cat ${OPENSHIFT_DATA_DIR}/params/hidrive_account)
hidrive_password=$(cat ${OPENSHIFT_DATA_DIR}/params/hidrive_password)

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
cat << '__HEREDOC__' > .netrc
machine webdav.hidrive.strato.com login __HIDRIVE_ACCOUNT__ password __HIDRIVE_PASSWORD__
__HEREDOC__
sed -i -e "s|__HIDRIVE_ACCOUNT__|${hidrive_account}|g" .netrc
sed -i -e "s|__HIDRIVE_PASSWORD__|${hidrive_password}|g" .netrc
chmod 600 .netrc
popd > /dev/null

# * webdav upload script *

cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/scripts/cadaver_put.sh
#!/bin/bash

if [ $# -ne 3 ]; then
    echo "NG"
    exit 1
fi

pushd ${1}
export HOME=${OPENSHIFT_DATA_DIR}
${OPENSHIFT_DATA_DIR}/cadaver/bin/./cadaver https://webdav.hidrive.strato.com/ << __HEREDOC_2__
cd ${2}
put ${3}
quit
__HEREDOC_2__
popd
exit 0
__HEREDOC__
chmod +x ${OPENSHIFT_DATA_DIR}/scripts/cadaver_put.sh

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
