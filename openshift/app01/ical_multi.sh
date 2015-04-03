#!/bin/bash

# ${1} : ical_server_name
# ${2} : ical_name

export TZ=JST-9

schedule_server="${1}"
target_uri="${2}"

connection_string_no_db=$(cat << __HEREDOC__
--user=${OPENSHIFT_MYSQL_DB_USERNAME}
--password=${OPENSHIFT_MYSQL_DB_PASSWORD}
--host=${OPENSHIFT_MYSQL_DB_HOST}
--port=${OPENSHIFT_MYSQL_DB_PORT}
--silent --batch --skip-column-names
__HEREDOC__
)

sql=$(cat << '__HEREDOC__'
SELECT COUNT('X')
  FROM SCHEMATA
 WHERE SCHEMA_NAME = 'baikal'
__HEREDOC__
)

cnt=$(mysql ${connection_string_no_db} --database=information_schema --execute="${sql}")
rc=$?
echo "${rc} database baikal count ${cnt}"
$([ ${rc} -eq 0 ] && [ ${cnt} -eq  1 ]) || exit

connection_string=$(cat << __HEREDOC__
${connection_string_no_db}
--database=baikal
__HEREDOC__
)

sql=$(cat << __HEREDOC__
SELECT COUNT('X') CNT
  FROM calendars T1
 WHERE T1.uri = '${target_uri}'
__HEREDOC__
)

cnt=$(mysql ${connection_string} --execute="${sql}")
echo $?
echo "${target_uri} count ${cnt}"

[ ${cnt} -ne 1 ] && exit

mkdir ${OPENSHIFT_DATA_DIR}/ics_files 2> /dev/null
pushd ${OPENSHIFT_DATA_DIR}/ics_files > /dev/null

[ -f ${target_uri}.ics ] && mv -f ${target_uri}.ics ${target_uri}.ics.old || touch ${target_uri}.ics.old
wget https://${schedule_server}/schedule/${target_uri} -O ${target_uri}.ics
cmp ${target_uri}.ics ${target_uri}.ics.old
if [ $? -eq 0 ]; then
    echo "${target_uri}.ics is not changed"
    exit
fi

sql=$(cat << __HEREDOC__
SELECT T1.id
  FROM calendars T1
 WHERE T1.uri = '${target_uri}'
__HEREDOC__
)

calendar_id=$(mysql ${connection_string} --execute="${sql}")
echo $?
echo "calendar_id : ${calendar_id}"

sql=$(cat << __HEREDOC__
DELETE
  FROM calendarobjects
 WHERE calendarid = ${calendar_id}
__HEREDOC__
)

mysql ${connection_string} --execute="${sql}"
echo $?
echo "delete"

cat ${target_uri}.ics | while read line
do
    if [ "${line}" = "BEGIN:VEVENT" ]; then
        event=""
        uid=""
        utime=0
    fi

    if [[ "${line}" =~ ^UID: ]]; then
        uid=${line:4}
    fi

    if [[ "${line}" =~ ^DTSTART.VALUE=DATE: ]]; then
        y=${line:19:4}
        m=${line:23:2}
        d=${line:25:2}
        utime=$(date "+%s" --date "${y}-${m}-${d}")
    fi

    event="${event}${line}\r\n"

    if [ "${line}" = "END:VEVENT" ]; then

        calendardata="BEGIN:VCALENDAR\r\nPRODID:dummy\r\nVERSION:2.0\r\n${event}END:VCALENDAR\r\n"

        sql=$(cat << __HEREDOC__
INSERT INTO calendarobjects
       (
         calendardata
        ,uri
        ,calendarid
        ,componenttype
        ,firstoccurence
       )
 VALUES (
         "${calendardata}"
        ,"${uid}"
        ,"${calendar_id}"
        ,"VEVENT"
        ,${utime}
        )
__HEREDOC__
)

        mysql ${connection_string} --execute="${sql}"
        echo $?
        echo "insert uid : ${uid}"
    fi
done

sql=$(cat << __HEREDOC__
UPDATE calendarobjects
   SET size = LENGTH(calendardata)
      ,etag = MD5(calendardata)
      ,lastmodified = unix_timestamp(now())
      ,lastoccurence = firstoccurence + 60 * 60 * 24
 WHERE calendarid = ${calendar_id}
__HEREDOC__
)

mysql ${connection_string} --execute="${sql}"
echo $?
echo "update"

popd > /dev/null
