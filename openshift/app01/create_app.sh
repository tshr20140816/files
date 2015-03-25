#!/bin/bash

set -x

[ $# -ne 1 ] && exit

export server=${1}

while :
do
    yes | rhc app delete -a ${server}
    yes | rhc app create ${server} diy-0.1 mysql-5.5 cron-1.4 phpmyadmin-4 --server openshift.redhat.com
    server_link=$(rhc apps | grep ssh | grep ${server} | awk '{print $3}' | awk -F/ '{print $3}')
    processor_count=$(ssh ${server_link} cat /proc/cpuinfo | grep processor | wc -l)
    [ ${processor_count} -eq 4 ] && exit
done
