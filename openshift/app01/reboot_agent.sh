#!/bin/bash

export TZ=JST-9

while :
do
    pushd ${OPENSHIFT_TMP_DIR} > /dev/null
    [ ! -f nohup_error.log.old ] && touch nohup_error.log.old
    cp -f ${OPENSHIFT_LOG_DIR}/nohup_error.log ./nohup_error.log.new
    # diff -u nohup_error.log.old nohup_error.log.new > diff_nohup_error.log
    diff --new-line-format='%L' --unchanged-line-format='' nohup_error.log.old nohup_error.log.new
    mv -f nohup_error.log.new nohup_error.log.old
    url="$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy"
    while read LINE
    do
        # if [[ "${LINE}" =~ ^\+\+\+ ]]; then
        #     :
        # elif [[ "${LINE}" =~ ^\+ ]]; then
        #     log_String=$(echo ${LINE:1} | perl -MURI::Escape -lne 'print uri_escape($_)')
        #     query_string="server=${OPENSHIFT_GEAR_DNS}&file=nohup_error&log=${log_String}"
        #     wget --spider "${url}?${query_string}" &
        # fi
        log_String=$(echo ${LINE:1} | perl -MURI::Escape -lne 'print uri_escape($_)')
        query_string="server=${OPENSHIFT_GEAR_DNS}&file=nohup_error&log=${log_String}"
        wget --spider "${url}?${query_string}" &
    done < diff_nohup_error.log
    popd > /dev/null

    if [ -f ${OPENSHIFT_DATA_DIR}/install_check_point/install_all.ok ]; then
        sleep 10s
        pushd ${OPENSHIFT_LOG_DIR} > /dev/null
        zip -9 ${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}.nohup_error.log.zip nohup_error.log
        rm -f nohup_error.log
        zip -9 ${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}.nohup.log.zip nohup.log
        rm -f nohup.log
        popd > /dev/null
        echo $(date +%Y/%m/%d" "%H:%M:%S) Good Bye
        exit
    fi

    if [ ! -f ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt ]; then
        sleep 5s
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
