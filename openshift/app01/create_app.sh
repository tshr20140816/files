#!/bin/bash

set -x

[ $# -ne 2 ] && exit

export type=${1}
export server=${2}

while :
do
    yes | rhc app delete -a ${server}
    case "${type}" in
        "diy" ) yes | rhc app create ${server} diy-0.1 mysql-5.5 cron-1.4 phpmyadmin-4 --server openshift.redhat.com
        ;;
        "php" ) yes | rhc app create ${server} php-5.4 cron-1.4 --server openshift.redhat.com
        ;;
        "ruby" ) yes | rhc app create ${server} ruby-2.0 cron-1.4 --server openshift.redhat.com
        ;;
        * ) exit
        ;;
    esac

    server_link=$(rhc apps | grep ssh | grep ${server} | awk '{print $3}' | awk -F/ '{print $3}')
    processor_count=$(ssh ${server_link} cat /proc/cpuinfo | grep -c processor)
    [ ${processor_count} -eq 4 ] && exit
done
