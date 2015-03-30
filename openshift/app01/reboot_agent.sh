#!/bin/bash

export TZ=JST-9

while :
do
    if [ -f ${OPENSHIFT_DATA_DIR}/install_check_point/install_all.ok ]; then
        sleep 10s
        pushd ${OPENSHIFT_LOG_DIR} > /dev/null
        zip -9 nohup_error.log.zip nohup_error.log
        rm -f nohup_error.log
        zip -9 nohup.log.zip nohup.log
        rm -f nohup.log
        popd > /dev/null
        echo $(date +%Y/%m/%d" "%H:%M:%S) Good Bye
        exit
    fi

    if [ ! -f ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt ]; then
        sleep 10s
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
