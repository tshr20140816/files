# return code 0 : resume 1 : skip
function010() {

    set -x

    export TZ=JST-9

    # ***** skip *****
    
    pushd ${OPENSHIFT_DATA_DIR}/install_check_point > /dev/null
    if [ -f "$(basename "${0}").ok" ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Skip $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
        return 1
    fi
    popd > /dev/null

    # 元に戻したい場合がでたときのため
    export env_home_backup=${HOME}

    # ***** ccache *****

    if [ -e ${OPENSHIFT_DATA_DIR}/ccache ]; then
        ccache_exists=$(printenv | grep ^PATH= | grep ccache | wc -l)
        if [ ${ccache_exists} -eq 0 ]; then
            export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
            export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
            export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
            rm -rf ${CCACHE_TEMPDIR}
            mkdir -p ${CCACHE_TEMPDIR}
            # export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
            export CCACHE_LOGFILE=/dev/null
            export CCACHE_NLEVELS=3
            export CCACHE_MAXSIZE=300M
        fi
    fi

    # ***** distcc *****

    if [ -e ${OPENSHIFT_DATA_DIR}/distcc ]; then
        distcc_exists=$(printenv | grep ^PATH= | grep distcc | wc -l)
        if [ ${distcc_exists} -eq 0 ]; then
            export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
            export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
            # export DISTCC_LOG=/dev/null
            export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc.log
            echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Start $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/distcc.log
        fi
    fi

    # ***** distcc hosts *****

    if [ -e ${OPENSHIFT_DATA_DIR}/params/distcc_hosts.txt ]; then
        tmp_string="$(cat ${OPENSHIFT_DATA_DIR}/params/distcc_hosts.txt)"
        export DISTCC_HOSTS="${tmp_string}"
        export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"
        export CC="distcc gcc"
        export CXX="distcc g++"
    fi

    # ***** distcc ssh *****

    if [ -e ${OPENSHIFT_DATA_DIR}/.ssh/config ]; then
        export DISTCC_SSH="${OPENSHIFT_DATA_DIR}/bin/distcc-ssh"
    fi

    # ***** ld.gold *****

    if [ -f ${OPENSHIFT_DATA_DIR}/download_files/ld.gold ]; then
        mkdir -p ${OPENSHIFT_TMP_DIR}/local/bin
        cp ${OPENSHIFT_DATA_DIR}/download_files/ld.gold ${OPENSHIFT_TMP_DIR}/local/bin/
        chmod +x ${OPENSHIFT_TMP_DIR}/local/bin/ld.gold
        export LD=ld.gold
        export PATH="${OPENSHIFT_TMP_DIR}/local/bin:$PATH"
    fi

    # ***** CFLAGS CXXFLAGS *****

    # NG : distcc & -march=native
    # export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
    # -march=ivybridge E5-2670 v2
    # export CFLAGS="-O2 -march=core2 -fomit-frame-pointer -s"
    # export CFLAGS="-O2 -march=core2 -maes -mavx -mcx16 -mpclmul -mpopcnt -msahf"
    # export CFLAGS="${CFLAGS} -msse -msse2 -msse3 -msse4 -msse4.1 -msse4.2 -mssse3 -mtune=generic"
    # export CFLAGS="${CFLAGS} -pipe -fomit-frame-pointer -s"
    cflag_data=$(gcc -march=native -E -v - </dev/null 2>&1 | sed -n 's/.* -v - //p')
    export CFLAGS="-O2 ${cflag_data} -pipe -fomit-frame-pointer -s"
    export CXXFLAGS="${CFLAGS}"

    # ***** memory.failcnt *****

    # shellcheck disable=SC2034
    processor_count="$(grep -c -e processor /proc/cpuinfo)"
    local mfc=$(oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $1}')
    local query_string="server=${OPENSHIFT_APP_DNS}&part=$(basename "${0}" .sh)&mfc=${mfc}"
    # if [ $(which ccache | wc -l) -eq 1 ]; then
    #     ccache_hit_direct=$(ccache -s | grep -e "^cache hit .direct" | awk '{print $4}')
    #     query_string="${query_string}&ccache_hit_direct=${ccache_hit_direct}"
    # fi
    wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1

    # ***** version information *****

    while read LINE
    do
        local product=$(echo "${LINE}" | awk '{print $1}')
        local version=$(echo "${LINE}" | awk '{print $2}')
        eval "${product}"="${version}"
    done < ${OPENSHIFT_DATA_DIR}/version_list

    # ***** stop and restart action *****

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
    local disk_usage=$(quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}')
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Disk Usage : ${disk_usage}" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    local memory_usage=$(oo-cgroup-read memory.usage_in_bytes | awk '{printf "%\047d\n", $1}')
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Memory Usage : ${memory_usage}" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    local memory_fail_count=$(oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $1}')
    echo "$(date +%Y/%m/%d" "%H:%M:%S) Memory Fail Count : ${memory_fail_count}" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

    return 0
}

# ${1} : database name
function020() {
    [ $# -ne 1 ] && return

    echo "Database Compress ${1}"

    mysql --user="${OPENSHIFT_MYSQL_DB_USERNAME}" \
     --password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
     --host="${OPENSHIFT_MYSQL_DB_HOST}" \
     --port="${OPENSHIFT_MYSQL_DB_PORT}" \
     --database="${1}" \
     --silent \
     --batch \
     --execute="SET GLOBAL innodb_file_per_table=1;SET GLOBAL innodb_file_format=Barracuda;"

    local tables=$(mysql --user="${OPENSHIFT_MYSQL_DB_USERNAME}" \
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
}

# ${1} : query string
function030() {
    [ $# -ne 1 ] && return
    url="$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?server=${OPENSHIFT_APP_DNS}&"
    wget --spider -b -q -o /dev/null "${url}${1}" > /dev/null 2>&1
    curl -H "content-type:application/x-www-form-urlencoded" \
     -d '{"message":"${1}", "from":"${OPENSHIFT_APP_DNS}"}' \
     http://logs-01.loggly.com/inputs/$(cat ${OPENSHIFT_DATA_DIR}/params/loggly_token)/tag/test/
}
