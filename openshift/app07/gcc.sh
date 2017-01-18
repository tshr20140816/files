#!/bin/bash

set -x

export TZ=JST-9

while :
do
	dt=$(date +%Y/%m/%d" "%H:%M:%S)
	usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
	usage_in_bytes_format=$(echo "${usage_in_bytes}" | awk '{printf "%\047d\n", $0}')
	echo "$dt $usage_in_bytes_format"
	if [ "${usage_in_bytes}" -lt 300000000 ]; then
		break
	fi
	sleep 1s
done

# export PATH="/bin:/usr/bin:/usr/sbin"
exec /usr/bin/gcc "$@"
