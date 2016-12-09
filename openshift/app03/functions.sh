function010() {

    set -x

    export TZ=JST-9
    export install_log=${OPENSHIFT_LOG_DIR}/install.log

    # ***** skip *****

    pushd ${OPENSHIFT_DATA_DIR}/install_check_point > /dev/null
    if [ -f "$(basename "${0}").ok" ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Skip $(basename "${0}")" | tee -a ${install_log}
        return 1
    fi
    popd > /dev/null

    # ***** version info *****

    while read -r LINE
    do
        product=$(echo "${LINE}" | awk '{print $1}')
        version=$(echo "${LINE}" | awk '{print $2}')
        eval "${product}"="${version}"
    done < ${OPENSHIFT_DATA_DIR}/version_list
}
