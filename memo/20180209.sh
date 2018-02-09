#!/bin/bash

file_name=/tmp/$(date '+%H%M').txt

ping -n 1 192.168.1.1 > ${file_name}

curl -iv4 --no-keepalive -A '1-2-3-4' https://logs >> ${file_name}
