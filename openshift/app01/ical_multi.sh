#!/bin/bash

# ${1} : ical_server_name
# ${2} : ical_name
# ${3} : [OPTIONAL] static url

[ $# -eq 2 ] || [ $# -eq 3 ] || exit

export TZ=JST-9

schedule_server="${1}"
target_uri="${2}"
static_url="none"
if [ $# -eq 3 ]; then
    static_url="${3}"
fi

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
  FROM information_schema.TABLES T1
 WHERE T1.TABLE_TYPE = 'BASE TABLE'
   AND T1.TABLE_SCHEMA = 'baikal'
   AND T1.TABLE_NAME = 'calendars'
__HEREDOC__
)

cnt=$(mysql ${connection_string_no_db} --database=information_schema --execute="${sql}")
rc=$?
echo "$(date +%Y/%m/%d" "%H:%M:%S) ${rc} database baikal count ${cnt}"
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
rc=$?
echo "$(date +%Y/%m/%d" "%H:%M:%S) ${rc} ${target_uri} count ${cnt}"
$([ ${rc} -eq 0 ] && [ ${cnt} -eq  1 ]) || exit

mkdir ${OPENSHIFT_DATA_DIR}/ics_files 2> /dev/null
pushd ${OPENSHIFT_DATA_DIR}/ics_files > /dev/null

[ -f ${target_uri}.ics ] && mv -f ${target_uri}.ics ${target_uri}.ics.old || touch ${target_uri}.ics.old
if [ ${static_url} = "none" ]; then
    wget https://${schedule_server}/schedule/${target_uri} -O ${target_uri}.ics
else
    wget ${static_url} -O ${target_uri}.ics
fi
cmp ${target_uri}.ics ${target_uri}.ics.old
if [ $? -eq 0 ]; then
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ${target_uri}.ics is not changed"
    exit
fi

sql=$(cat << __HEREDOC__
SELECT T1.id
  FROM calendars T1
 WHERE T1.uri = '${target_uri}'
__HEREDOC__
)

calendar_id=$(mysql ${connection_string} --execute="${sql}")
rc=$?
echo "$(date +%Y/%m/%d" "%H:%M:%S) ${rc} calendar_id : ${calendar_id}"

sql=$(cat << __HEREDOC__
DELETE
  FROM calendarobjects
 WHERE calendarid = ${calendar_id}
__HEREDOC__
)

mysql ${connection_string} --execute="${sql}"
rc=$?
echo "$(date +%Y/%m/%d" "%H:%M:%S) ${rc} delete"

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
    elif [[ "${line}" =~ ^DTSTART.2 ]]; then
        y=${line:8:4}
        m=${line:12:2}
        d=${line:14:2}
        utime=$(date "+%s" --date "${y}-${m}-${d}")
        line="DTSTART;VALUE=DATE:${y}${m}${d}"
    fi
    
    if [[ "${line}" =~ ^DTEND.2 ]]; then
        line="DTEND;VALUE=DATE:${line:6:8}"
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
        rc=$?
        echo "$(date +%Y/%m/%d" "%H:%M:%S) ${rc} insert uid : ${uid}"
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
rc=$?
echo "$(date +%Y/%m/%d" "%H:%M:%S) ${rc} update"

popd > /dev/null
