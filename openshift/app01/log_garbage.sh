#!/bin/bash

[ $# -ne 1 ] || exit
[ -f ${log_name} ] || exit

log_name="${1}"

for index in 6 5 4 3 2 1
do
    [ -f ${log_name}.${index} ] && mv -f ${log_name}.${index} ${log_name}.$((index + 1))
done

mv ${log_name} ${log_name}.1
