# return code 0 : resume 1 : skip
function010 {

    export TZ=JST-9
    
    wget --spider $(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?server=${OPENSHIFT_GEAR_DNS}\&part=$(basename $0 .sh) \
    > /dev/null 2>&1

    while read LINE
    do
        product=`echo ${LINE} | awk '{print $1}'`
        version=`echo ${LINE} | awk '{print $2}'`
        eval "${product}"=${version}
    done < ${OPENSHIFT_DATA_DIR}/version_list

    set -x

    pushd ${OPENSHIFT_DATA_DIR}/install_check_point > /dev/null
    if [ -f `basename $0`.ok ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` Install Skip `basename $0` | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        return 1
    fi
    popd > /dev/null

    # restart
    /usr/bin/gear stop
    /usr/bin/gear start

    echo `date +%Y/%m/%d" "%H:%M:%S` Install Start `basename $0` \
    | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` \
    | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo `oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}'` \
    | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo `oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}'` \
    | tee -a ${OPENSHIFT_LOG_DIR}/install.log

    return 0
}
