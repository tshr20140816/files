#!/bin/bash

export TZ=JST-9

if [ $# -ne 2 ]; then
    exit
fi
install_script_file=${1}
web_beacon_server=${2}

loop_counter=0

while :
do
    if [ -f ${OPENSHIFT_DATA_DIR}/install_check_point/install_all.ok ]; then
        sleep 10s
        pushd ${OPENSHIFT_LOG_DIR} > /dev/null
        url="$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy"
        for file_name in nohup nohup_error
        do
            i=0
            while read LINE
            do
                i=$((i+1))
                log_String=$(echo ${LINE} | tr " " "_" | perl -MURI::Escape -lne 'print uri_escape($_)')
                query_string="server=${OPENSHIFT_GEAR_DNS}&file=${file_name}&log=${i}_${log_String}"
                wget --spider -b -q -o /dev/null "${url}?${query_string}" > /dev/null 2>&1
            done < ${file_name}.log
            zip -9 ${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}.${file_name}.log.zip ${file_name}.log
            rm -f ${file_name}.log
            curl 
        done
        popd > /dev/null
        wait
        echo $(date +%Y/%m/%d" "%H:%M:%S) Good Bye
        exit
    fi

    if [ ! -f ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt ]; then
        if [ ${loop_counter} -gt 10 ]; then
            loop_counter=0
            is_alive=$(ps ahwx | grep ${install_script_file} | grep ${OPENSHIFT_DIY_IP} | grep -c -v grep)
            query_string="server=${OPENSHIFT_GEAR_DNS}&install_script_is_alive=${is_alive}"
            wget --spider "${web_beacon_server}dummy?${query_string}" > /dev/null 2>&1
        fi
        sleep 5s
        loop_counter=$((${loop_counter}+1))
        continue
    fi

    case "$(cat ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt)" in
        "restart" )
            echo $(date +%Y/%m/%d" "%H:%M:%S) gear restart
            query_string="server=${OPENSHIFT_GEAR_DNS}&action=restart"
            wget --spider $(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string} > /dev/null 2>&1
    
            /usr/bin/gear stop --trace
            /usr/bin/gear start --trace
            ;;
        "stop" )
            echo $(date +%Y/%m/%d" "%H:%M:%S) gear stop
            query_string="server=${OPENSHIFT_GEAR_DNS}&action=stop"
            wget --spider $(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string} > /dev/null 2>&1
    
            /usr/bin/gear stop --trace
            ;;
        "start" )
            echo $(date +%Y/%m/%d" "%H:%M:%S) gear start
            query_string="server=${OPENSHIFT_GEAR_DNS}&action=start"
            wget --spider $(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string} > /dev/null 2>&1
    
            /usr/bin/gear start --trace
            ;;
    esac
    rm -f ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt
done
