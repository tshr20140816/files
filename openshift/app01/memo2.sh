#!/bin/bash

export TZ=JST-9

sql=$(cat << '__HEREDOC__'
SELECT COUNT('X') CNT
  FROM calendars T1
 WHERE T1.uri = 'carp'
__HEREDOC__)

cnt=(`mysql --user="${OPENSHIFT_MYSQL_DB_USERNAME}" \
 --password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
 --host="${OPENSHIFT_MYSQL_DB_HOST}" \
 --port="${OPENSHIFT_MYSQL_DB_PORT}" \
 --database="baikal" \
 --silent \
 --batch \
 --skip-column-names \
 --execute="${sql}"`)

if [ ${cnt} -ne 1 ]; then
    exit
fi

cd ${OPENSHIFT_TMP_DIR}

[ -f carp.ics ] && mv -f carp.ics carp.ics.old || touch carp.ics.old
wget tshrapp4.appspot.com/schedule/carp -O carp.ics
cmp carp.ics carp.ics.old
[ $? -eq 0 ] && exit

echo carp

sql=$(cat << '__HEREDOC__'
SELECT T1.id
  FROM calendars T1
 WHERE T1.uri = 'carp'
__HEREDOC__)

calendar_id=(`mysql --user="${OPENSHIFT_MYSQL_DB_USERNAME}" \
 --password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
 --host="${OPENSHIFT_MYSQL_DB_HOST}" \
 --port="${OPENSHIFT_MYSQL_DB_PORT}" \
 --database="baikal" \
 --silent \
 --batch \
 --skip-column-names \
 --execute="${sql}"`)

event=()
cat carp.ics | while read line
do
    echo ${line}
    if [ "${line}" = "BEGIN:VEVENT" ]; then
        created=""
        uid=""
        dtstart=""
        summary=""
    fi

    if [ "${line}" =~ ^CREATED: ]; then
        created=${line:8}
        y=${line:8:4}
        m=${line:12:2}
        d=${line:14:2}
        h=${line:17:2}
        n=${line:19:2}
        s=${line:21:2}
    fi

    if [ "${line}" =~ ^UID: ]; then
        uid=${line:4}
    fi

    if [ "${line}" =~ ^DTSTART: ]; then
        dtstart=${line:8}
    fi

    if [ "${line}" =~ ^SUMMARY: ]; then
        summary=${line:8}
    fi

    if [ "${line}" = "END:VEVENT" ]; then


sql=$(cat << '__HEREDOC__'
INSERT INTO calendars
       (
       )
 VALUES (
        )
__HEREDOC__)

    fi
done
