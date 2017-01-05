#!/bin/bash

export TZ=JST-9

while :
do
	dt=$(date +%Y/%m/%d" "%H:%M:%S)
	usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
	usage_in_bytes_format=$(echo "${usage_in_bytes}" | awk '{printf "%\047d\n", $0}')
	if [ "${usage_in_bytes}" -lt 300000000 ]; then
		break
	fi
	echo "$dt $usage_in_bytes_format"
	sleep 1s
done

exec /usr/bin/gcc $@
