#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** sphinx *****

# https://blog.openshift.com/easy-full-text-search-with-sphinx/

rm -f ${OPENSHIFT_TMP_DIR}/sphinx-${sphinx_version}-release.tar.xz
rm -f ${OPENSHIFT_TMP_DIR}/${OPENSHIFT_APP_UUID}_maked_sphinx-${sphinx_version}.tar.xz
rm -rf ${OPENSHIFT_TMP_DIR}/sphinx-${sphinx_version}
rm -rf ${OPENSHIFT_DATA_DIR}/sphinx

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    file_name=${OPENSHIFT_APP_UUID}_maked_sphinx-${sphinx_version}.tar.xz
    url=$(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    while :
    do
        if [ $(wget -nv --spider --timeout 60 -t 1 ${url} 2>&1 | grep -c '200 OK') -eq 1 ]; then
            echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx maked wget" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            break
        else
            echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx maked waiting" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
            sleep 10s
        fi
    done
    wget $(cat ${OPENSHIFT_DATA_DIR}/params/mirror_server)/${file_name}
    echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx maked tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar Jxf ${file_name}
    rm -f ${file_name}
else
    cp -f ${OPENSHIFT_DATA_DIR}/download_files/sphinx-${sphinx_version}-release.tar.xz ./
    echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    tar jxf sphinx-${sphinx_version}-release.tar.xz
fi
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/sphinx-${sphinx_version} > /dev/null

# *** configure make install ***

if [ $(cat ${OPENSHIFT_DATA_DIR}/params/build_server_password) != "none" ]; then
    export CC="ccache gcc"
    export CXX="ccache g++"
else
    echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_sphinx.log
    ./configure \
     --prefix=${OPENSHIFT_DATA_DIR}/sphinx \
     --mandir=/tmp/man \
     --infodir=/tmp/info \
     --docdir=/tmp/doc \
     --disable-dependency-tracking \
     --disable-id64 \
     --with-mysql \
     --without-syslog 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_sphinx.log
    echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
    echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_sphinx.log
    # time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_sphinx.log
    time make 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_sphinx.log
fi

echo "$(date +%Y/%m/%d" "%H:%M:%S) sphinx make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_sphinx.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_sphinx.log
mv ${OPENSHIFT_LOG_DIR}/install_sphinx.log ${OPENSHIFT_LOG_DIR}/install/
popd > /dev/null

unset CC
unset CXX

# *** config ***

pushd ${OPENSHIFT_DATA_DIR}/sphinx > /dev/null
cat << '__HEREDOC__' > sphinx.conf
source ttrss
{
    type = mysql
    sql_host = __OPENSHIFT_MYSQL_DB_HOST__
    sql_user = __OPENSHIFT_MYSQL_DB_USERNAME__
    sql_pass = __OPENSHIFT_MYSQL_DB_PASSWORD__
    sql_db = ttrss
    sql_port = 3306
    sql_query_pre = SET NAMES utf8
    sql_query = \
        SELECT int_id AS id, ref_id, UNIX_TIMESTAMP(updated) AS updated, \
            ttrss_entries.title AS title, link, content, \
            ttrss_feeds.title AS feed_title, \
            marked, published, unread, \
            author, ttrss_user_entries.owner_uid \
        FROM ttrss_entries, ttrss_user_entries, ttrss_feeds \
        WHERE ref_id = ttrss_entries.id AND feed_id = ttrss_feeds.id;

    # sql_attr_uint = owner_uid
    # sql_attr_uint = ref_id

    sql_ranged_throttle = 0

    sql_query_info = \
        SELECT * FROM ttrss_entries, \
            ttrss_user_entries WHERE ref_id = id AND int_id=$id
}

source delta : ttrss {
    sql_query = \
        SELECT int_id AS id, ref_id, UNIX_TIMESTAMP(updated) AS updated, \
            ttrss_entries.title AS title, link, content, \
            ttrss_feeds.title AS feed_title, \
            marked, published, unread, \
            author, ttrss_user_entries.owner_uid \
        FROM ttrss_entries, ttrss_user_entries, ttrss_feeds \
        WHERE ref_id = ttrss_entries.id AND feed_id = ttrss_feeds.id \
        AND ttrss_entries.updated > NOW() - INTERVAL 24 HOUR;

    sql_query_killlist = \
        SELECT int_id FROM ttrss_entries, ttrss_user_entries \
            WHERE ref_id = ttrss_entries.id AND updated > NOW() - INTERVAL 24 HOUR;
}

index ttrss {
    source = ttrss
    path = __OPENSHIFT_DATA_DIR__/sphinx/ttrss
    docinfo = extern
    mlock = 0
    morphology = none
    min_word_len = 1
    charset_type = utf-8
    min_prefix_len = 3
    prefix_fields = title, content, feed_title, author
    enable_star = 1
    html_strip = 1
}

index delta : ttrss {
    source = delta
    path = __OPENSHIFT_DATA_DIR__/sphinx/ttrss_delta
}

indexer {
    mem_limit = 32M
}

searchd {
    log = __OPENSHIFT_LOG_DIR__/sphinx_searchd.log
    query_log = __OPENSHIFT_LOG_DIR__/sphinx_query.log
    read_timeout = 5
    client_timeout = 300
    max_children = 30
    pid_file = __OPENSHIFT_DATA_DIR__/sphinx/searchd.pid
    max_matches = 1000
    seamless_rotate = 1
    preopen_indexes = 1
    unlink_old = 1
    mva_updates_pool = 1M
    max_packet_size = 8M
    max_filters = 256
    max_filter_values = 4096
}
__HEREDOC__
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -f sphinx-${sphinx_version}-release.tar.xz
rm -rf sphinx-${sphinx_version}
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
