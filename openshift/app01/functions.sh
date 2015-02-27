# return code 0 : resume 1 : skip
function010() {

    export TZ=JST-9

    set -x

    processor_count=$(cat /proc/cpuinfo | grep processor | wc -l)
    mfc=$(oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $1}')
    query_string="server=${OPENSHIFT_GEAR_DNS}&part=$(basename $0 .sh)&mfc=${mfc}"

    wget --spider $(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string} \
    > /dev/null 2>&1

    pushd ${OPENSHIFT_DATA_DIR}/install_check_point > /dev/null
    if [ -f $(basename $0).ok ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` Install Skip $(basename $0) | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        return 1
    fi
    popd > /dev/null
    
    while read LINE
    do
        product=`echo ${LINE} | awk '{print $1}'`
        version=`echo ${LINE} | awk '{print $2}'`
        eval "${product}"=${version}
    done < ${OPENSHIFT_DATA_DIR}/version_list

    if [ $# -gt 0 -o ${1} = "no_restart" ]; then
        :
    elif
        echo "restart" > ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt
        sleep 30s
        while :
        do
            [ -f ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt ] && sleep 10s || break
        done
    fi

    echo $(date +%Y/%m/%d" "%H:%M:%S) Install Start $(basename $0) \
    | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $(quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}') \
    | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $(oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}') \
    | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $(oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}') \
    | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $(oo-cgroup-read memory.memsw.failcnt | awk '{printf "Swap Memory Fail Count : %\047d\n", $1}') \
    | tee -a ${OPENSHIFT_LOG_DIR}/install.log

    return 0
}
