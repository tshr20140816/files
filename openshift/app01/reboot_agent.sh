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

        # ***** compressed files *****
        
        pushd ${OPENSHIFT_DATA_DIR} > /dev/null
        rm -f compressed_files.zip
        rm -rf compressed
        find ${OPENSHIFT_DATA_DIR} -name "*.css" -mindepth 2 -type f -print > compress_target_list_css.txt
        find ${OPENSHIFT_DATA_DIR} -name "*.js" -mindepth 2 -type f -print > compress_target_list_js.txt
        find ${OPENSHIFT_DATA_DIR} -name "*.png" -mindepth 2 -type f -print > compress_target_list_png_gif.txt
        find ${OPENSHIFT_DATA_DIR} -name "*.gif" -mindepth 2 -type f -print >> compress_target_list_png_gif.txt
        wget https://$(head -n1 ${OPENSHIFT_DATA_DIR}/params/fqdn.txt)/compressed_files.zip
        unzip -q compressed_files.zip
        suffix=$(date '+%Y%m%d')
        while read LINE
        do
            target_file=${LINE}
            compressed_file=$(echo ${target_file} | sed -e "s|${OPENSHIFT_DATA_DIR}|${OPENSHIFT_DATA_DIR}/compressed/|g")
            [ ! -f ${compressed_file} ] && continue
            [ ! -f ${compressed_file}.compressed ] && continue
            [ $(wc -c < ${target_file}) -le $(wc -c < ${compressed_file}.compressed) ] && continue
            cmp ${target_file} ${compressed_file}
            [ $? -ne 0 ] && continue
            mv ${target_file} ${target_file}.${suffix}
            mv ${compressed_file}.compressed ${target_file}
        done < compress_target_list_css.txt
        rm -f compress_target_list_css.txt
        while read LINE
        do
            target_file=${LINE}
            compressed_file=$(echo ${target_file} | sed -e "s|${OPENSHIFT_DATA_DIR}|${OPENSHIFT_DATA_DIR}/compressed/|g")
            [ ! -f ${compressed_file} ] && continue
            [ ! -f ${compressed_file}.compressed ] && continue
            [ ! -f ${compressed_file}.result.txt ] && continue
            [ "$(cat ${compressed_file}.result.txt)" != "0 error(s), 0 warning(s)" ] && continue
            [ $(wc -c < ${target_file}) -le $(wc -c < ${compressed_file}.compressed) ] && continue
            cmp ${target_file} ${compressed_file}
            [ $? -ne 0 ] && continue
            mv ${target_file} ${target_file}.${suffix}
            mv ${compressed_file}.compressed ${target_file}
        done < compress_target_list_js.txt
        rm -f compress_target_list_js.txt
        while read LINE
        do
            target_file=${LINE}
            compressed_file=$(echo ${target_file} | sed -e "s|${OPENSHIFT_DATA_DIR}|${OPENSHIFT_DATA_DIR}/compressed/|g")
            [ ! -f ${compressed_file} ] && continue
            [ ! -f ${compressed_file}.compressed ] && continue
            [ $(wc -c < ${target_file}) -le $(wc -c < ${compressed_file}.compressed) ] && continue
            cmp ${target_file} ${compressed_file}
            [ $? -ne 0 ] && continue
            mv ${target_file} ${target_file}.${suffix}
            mv ${compressed_file}.compressed ${target_file}
        done < compress_target_list_png_gif.txt
        rm -f compress_target_list_png_gif.txt
        rm -f compressed_files.zip
        rm -rf compressed
        popd > /dev/null

        # ****** YUI Compressor *****
        find ${OPENSHIFT_DATA_DIR} -name "*.css" -mindepth 2 -type f -print0 \
         | xargs -0i -P 4 -n 1 ${OPENSHIFT_DATA_DIR}/scripts/yuicompressor.sh {}
        pushd ${OPENSHIFT_LOG_DIR} > /dev/null
        zip -9 ${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}.yuicompressor.log.zip yuicompressor.log
        rm -f yuicompressor.log
        mv -f ${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}.yuicompressor.log.zip ./install/
        popd > /dev/null

        # ****** Closure Compiler *****
        find ${OPENSHIFT_DATA_DIR} -name "*.js" -mindepth 2 -type f -print0 \
         | xargs -0i -P 6 -n 1 ${OPENSHIFT_DATA_DIR}/scripts/closure_compiler.sh {}
        pushd ${OPENSHIFT_LOG_DIR} > /dev/null
        zip -9 ${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}.closure_compiler.log.zip closure_compiler.log
        rm -f closure_compiler.log
        mv -f ${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}.closure_compiler.log.zip ./install/
        popd > /dev/null

        # ****** optipng *****
        find ${OPENSHIFT_DATA_DIR} -name "*.png" -mindepth 2 -type f -print0 \
         | xargs -0i -P 4 -n 1 ${OPENSHIFT_DATA_DIR}/scripts/optipng.sh {}
        find ${OPENSHIFT_DATA_DIR} -name "*.gif" -mindepth 2 -type f -print0 \
         | xargs -0i -P 4 -n 1 ${OPENSHIFT_DATA_DIR}/scripts/optipng.sh {}
        pushd ${OPENSHIFT_LOG_DIR} > /dev/null
        zip -9 ${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}.optipng.log.zip optipng.log
        rm -f optipng.log
        mv -f ${OPENSHIFT_APP_NAME}-${OPENSHIFT_NAMESPACE}.optipng.log.zip ./install/
        popd > /dev/null
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Good Bye"
        exit
    fi

    if [ ! -f ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt ]; then
        if [ ${loop_counter} -gt 20 ]; then
            loop_counter=0
            # is_alive=$(ps ahwx | grep ${install_script_file} | grep ${OPENSHIFT_DIY_IP} | grep -c -v grep)
            is_alive=$(pgrep -fl ${install_script_file} | grep ${OPENSHIFT_DIY_IP} | grep -c -v grep)
            mfc=$(oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $1}')
            query_string="server=${OPENSHIFT_APP_DNS}&install_script_is_alive=${is_alive}&mfc=${mfc}"
            wget --spider "${web_beacon_server}dummy?${query_string}" > /dev/null 2>&1
        fi
        sleep 5s
        loop_counter=$((loop_counter+1))
        continue
    fi

    case "$(cat ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt)" in
        "restart" )
            echo "$(date +%Y/%m/%d" "%H:%M:%S) gear restart"
            query_string="server=${OPENSHIFT_APP_DNS}&action=restart"
            wget --spider ${web_beacon_server}dummy?${query_string} > /dev/null 2>&1
    
            /usr/bin/gear stop --trace
            /usr/bin/gear start --trace
            ;;
        "stop" )
            echo "$(date +%Y/%m/%d" "%H:%M:%S) gear stop"
            query_string="server=${OPENSHIFT_APP_DNS}&action=stop"
            wget --spider ${web_beacon_server}dummy?${query_string} > /dev/null 2>&1
    
            /usr/bin/gear stop --trace
            ;;
        "start" )
            echo "$(date +%Y/%m/%d" "%H:%M:%S) gear start"
            query_string="server=${OPENSHIFT_APP_DNS}&action=start"
            wget --spider ${web_beacon_server}dummy?${query_string} > /dev/null 2>&1
    
            /usr/bin/gear start --trace
            ;;
    esac
    rm -f ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt
done
