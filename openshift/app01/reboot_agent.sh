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
        # ***** Log Compress *****
        pushd ${OPENSHIFT_LOG_DIR} > /dev/null
        # url="${web_beacon_server}dummy"
        for file_name in install nohup nohup_error distcc
        do
            # i=0
            # while read LINE
            # do
            #     i=$((i+1))
            #     log_String=$(echo ${LINE} | tr " " "_" | tr "+" "x" | perl -MURI::Escape -lne 'print uri_escape($_)')
            #     query_string="server=${OPENSHIFT_APP_DNS}&file=${file_name}&log=${i}_${log_String}"
            #     wget --spider -b -q -o /dev/null "${url}?${query_string}" > /dev/null 2>&1
            # done < ${file_name}.log
            if [ "${file_name}" != "install" ]; then
                zip -9 ${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}.${file_name}.log.zip ${file_name}.log
                rm -f ${file_name}.log
                mv -f ${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}.${file_name}.log.zip ./install/
            fi
        done
        rm -f dummy*
        popd > /dev/null
        # ****** Closure Compiler *****
        pushd ${OPENSHIFT_TMP_DIR} > /dev/null
        suffix=$(date '+%Y%m%d')
        while read target_file
        do
            if [ ! -f ./compiler.jar ]; then
                rm -f compiler-latest.zip
                wget http://dl.google.com/closure-compiler/compiler-latest.zip
                unzip compiler-latest.zip
                rm -f compiler-latest.zip
            fi
            compiled_file=./$(basename ${target_file})
            result_file=${compiled_file}.result.txt
            rm -f ${compiled_file}
            rm -f ${result_file}
            time java -jar ${OPENSHIFT_TMP_DIR}/compiler.jar \
             --summary_detail_level 3 \
             --compilation_level SIMPLE_OPTIMIZATIONS \
             --js ${target_file} \
             --js_output_file ${compiled_file} \
             2> ${result_file}
            if [ "$(cat ${result_file})" = "0 error(s), 0 warning(s)" ]; then
                size_original=$(wc -c < ${target_file})
                size_compiled=$(wc -c < ${compiled_file})
                if [ ${size_original} -gt ${size_compiled} ]; then
                    echo "$(date +%Y/%m/%d" "%H:%M:%S) CHANGED ${size_original} ${size_compiled} ${target_file}"
                     >> ${OPENSHIFT_LOG_DIR}/closure_compiler.log
                    cp -f ${target_file} ${target_file}.${suffix}
                    mv -f ${compiled_file} ${target_file}
                else
                    echo "$(date +%Y/%m/%d" "%H:%M:%S) NOT CHANGED (SIZE UP) ${size_original} ${size_compiled} ${file_name}" \
                     >> ${OPENSHIFT_LOG_DIR}/closure_compiler.log
                    rm -f ${compiled_file}
                fi
            else
                echo "$(date +%Y/%m/%d" "%H:%M:%S) NOT CHANGED (ERROR OR WARNING) ${file_name}"
                 >> ${OPENSHIFT_LOG_DIR}/closure_compiler.log
                cat ${result_file} >> ${OPENSHIFT_LOG_DIR}/closure_compiler.log
            fi
        done < ${OPENSHIFT_DATA_DIR}/javascript_compress_target_list.txt
        popd > /dev/null
        pushd ${OPENSHIFT_LOG_DIR} > /dev/null
            zip -9 ${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}.closure_compiler.log.zip closure_compiler.log
            rm -f closure_compiler.log
            mv -f ${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}.closure_compiler.log.zip ./install/
        popd > /dev/null
        echo $(date +%Y/%m/%d" "%H:%M:%S) Good Bye
        exit
    fi

    if [ ! -f ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt ]; then
        if [ ${loop_counter} -gt 20 ]; then
            loop_counter=0
            is_alive=$(ps ahwx | grep ${install_script_file} | grep ${OPENSHIFT_DIY_IP} | grep -c -v grep)
            query_string="server=${OPENSHIFT_APP_DNS}&install_script_is_alive=${is_alive}"
            wget --spider "${web_beacon_server}dummy?${query_string}" > /dev/null 2>&1
        fi
        sleep 5s
        loop_counter=$((${loop_counter}+1))
        continue
    fi

    case "$(cat ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt)" in
        "restart" )
            echo $(date +%Y/%m/%d" "%H:%M:%S) gear restart
            query_string="server=${OPENSHIFT_APP_DNS}&action=restart"
            wget --spider ${web_beacon_server}dummy?${query_string} > /dev/null 2>&1
    
            /usr/bin/gear stop --trace
            /usr/bin/gear start --trace
            ;;
        "stop" )
            echo $(date +%Y/%m/%d" "%H:%M:%S) gear stop
            query_string="server=${OPENSHIFT_APP_DNS}&action=stop"
            wget --spider ${web_beacon_server}dummy?${query_string} > /dev/null 2>&1
    
            /usr/bin/gear stop --trace
            ;;
        "start" )
            echo $(date +%Y/%m/%d" "%H:%M:%S) gear start
            query_string="server=${OPENSHIFT_APP_DNS}&action=start"
            wget --spider ${web_beacon_server}dummy?${query_string} > /dev/null 2>&1
    
            /usr/bin/gear start --trace
            ;;
    esac
    rm -f ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt
done
