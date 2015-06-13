#!/bin/bash

export TZ=JST-9
while :
do
  dt=$(date +%Y/%m/%d" "%H:%M:%S)
  usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
  usage_in_bytes_format=$(echo "${usage_in_bytes}" | awk '{printf "%\047d\n", $0}')
  failcnt=$(oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $0}')
  disk_usage=$(quota -s | grep -v a | awk '{print $1,$4}')
  # echo $dt $usage_in_bytes $failcnt
  if [ "${usage_in_bytes}" -gt 400000000 ]; then
    echo -e "$dt" "\e[33m${usage_in_bytes_format}\e[m" "$failcnt $disk_usage"
  else
    echo "$dt $usage_in_bytes_format $failcnt $disk_usage"
  fi
  sleep 1s
done
