# return code 0 : resume 1 : skip
function010() {

    export TZ=JST-9
    # export MAKEFLAGS="-j $(grep -c -e processor /proc/cpuinfo)"

    if [ -e ${OPENSHIFT_DATA_DIR}/ccache ]; then
        ccache_exists=$(printenv | grep ^PATH= | grep ccache | wc -l)
        if [ ${ccache_exists} -eq 0 ]; then
            export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
        fi

        export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
        export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
        export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
        export CCACHE_MAXSIZE=300M

        ccache_size=$(ccache -s | grep -e "^cache size" | awk '{print $3$4}')
        ccache_hit_direct=$(ccache -s | grep -e "^cache hit .direct" | awk '{print $4}')
        ccache_hit_preprocessed=$(ccache -s | grep -e "^cache hit .preprocessed" | awk '{print $4}')
    fi

    set -x

    # shellcheck disable=SC2034
    processor_count="$(grep -c -e processor /proc/cpuinfo)"
    mfc=$(oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $1}')
    query_string="server=${OPENSHIFT_GEAR_DNS}&part=$(basename "${0}" .sh)&mfc=${mfc}"

    wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

    pushd ${OPENSHIFT_DATA_DIR}/install_check_point > /dev/null
    if [ -f "$(basename "${0}").ok" ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Skip $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        return 1
    fi
    popd > /dev/null
    
    while read LINE
    do
        product=$(echo "${LINE}" | awk '{print $1}')
        version=$(echo "${LINE}" | awk '{print $2}')
        eval "${product}"="${version}"
    done < ${OPENSHIFT_DATA_DIR}/version_list

    if [ $# -gt 0 ]; then
        if [ "${1}" = "restart" -o "${1}" = "stop" ]; then
            echo "${1}" > ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt
            sleep 30s
            while :
            do
                [ -f ${OPENSHIFT_DATA_DIR}/install_check_point/gear_action.txt ] && sleep 10s || break
            done
            if [ "${1}" = "restart" ]; then
                sqls=()
                sqls=("${sqls[@]}" "SET GLOBAL default_storage_engine=InnoDB;")
                sqls=("${sqls[@]}" "SET GLOBAL time_zone='+9:00';")
                sqls=("${sqls[@]}" "SET GLOBAL innodb_file_per_table=1;")
                sqls=("${sqls[@]}" "SET GLOBAL innodb_file_format=Barracuda;")

                for (( i = 0; i < ${#sqls[@]}; i++ )); do

                    mysql --user="${OPENSHIFT_MYSQL_DB_USERNAME}" \
                     --password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
                     --host="${OPENSHIFT_MYSQL_DB_HOST}" \
                     --port="${OPENSHIFT_MYSQL_DB_PORT}" \
                     --silent \
                     --batch \
                     --execute="${sqls[$i]}"

                done
            fi
        fi
    fi

    echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Start $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    # quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}' \
    #  | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    # oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}' \
    #  | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    # oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}' \
    #  | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    disk_usage=$(quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}')
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Disk Usage : ${disk_usage}" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    memory_usage=$(oo-cgroup-read memory.usage_in_bytes | awk '{printf "Memory Usage : %\047d\n", $1}')
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Memory Usage : ${memory_usage}" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    memory_fail_count=$(oo-cgroup-read memory.failcnt | awk '{printf "Memory Fail Count : %\047d\n", $1}')
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Memory Fail Count : ${memory_fail_count}" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

    if [ $(which ccache | wc -l) -eq 1 ]; then
        ccache_size=$(ccache -s | grep -e "^cache size" | awk '{print $3$4}')
        ccache_hit_direct=$(ccache -s | grep -e "^cache hit .direct" | awk '{print $4}')
        ccache_hit_preprocessed=$(ccache -s | grep -e "^cache hit .preprocessed" | awk '{print $4}')
        echo "$(date +%Y/%m/%d" "%H:%M:%S) ccache size : ${ccache_size}" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) ccache hit direct : ${ccache_hit_direct}" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        echo "$(date +%Y/%m/%d" "%H:%M:%S) ccache hit preprocessed : ${ccache_hit_preprocessed}" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    fi
    return 0
}

# ${1} : database name
function020() {
    if [ $# -ne 1 ]; then
        return
    fi

    echo "Database Compress ${1}"

    mysql --user="${OPENSHIFT_MYSQL_DB_USERNAME}" \
     --password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
     --host="${OPENSHIFT_MYSQL_DB_HOST}" \
     --port="${OPENSHIFT_MYSQL_DB_PORT}" \
     --database="${1}" \
     --silent \
     --batch \
     --execute="SET GLOBAL innodb_file_per_table=1;SET GLOBAL innodb_file_format=Barracuda;"

    tables=$(mysql --user="${OPENSHIFT_MYSQL_DB_USERNAME}" \
     --password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
     --host="${OPENSHIFT_MYSQL_DB_HOST}" \
     --port="${OPENSHIFT_MYSQL_DB_PORT}" \
     --database="${1}" \
     --silent \
     --batch \
     --skip-column-names \
     --execute="SHOW TABLES")

    for table in ${tables[@]}; do
        for size in 1 2 4 8 16; do
            mysql --user="${OPENSHIFT_MYSQL_DB_USERNAME}" \
             --password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
             --host="${OPENSHIFT_MYSQL_DB_HOST}" \
             --port="${OPENSHIFT_MYSQL_DB_PORT}" \
             --database="${1}" \
             --silent \
             --batch \
             --execute="ALTER TABLE ${table} ENGINE=InnoDB ROW_FORMAT=compressed KEY_BLOCK_SIZE=${size};"
            if [ $? -eq 0 ]; then
                echo "${table} KEY_BLOCK_SIZE=${size}"
                break
            fi
        done
    done

    # select * from information_schema.INNODB_CMP
}
