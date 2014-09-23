#!/bin/bash

export TZ=JST-9
while :
do
  dt=`date +%Y/%m/%d" "%H:%M:%S`
  usage_in_bytes=`oo-cgroup-read memory.usage_in_bytes | awk '{printf "%\047d\n", $0}'`;
  failcnt=`oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $0}'`;
  echo $dt $usage_in_bytes $failcnt;
  sleep 1s;
done;
