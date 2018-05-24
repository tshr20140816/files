#!/bin/bash

ymd=$(date '+%Y%m%d')
cd /var/log

files[0]="syslog"
files[1]="messages"
files[2]="auth.log"
files[3]="mail.info"
files[4]="mail.warn"
files[5]="mail.log"
files[6]="daemon.log"
files[7]="user.log"

for file in "${files[@]}"; do
  file_name=${file}.${ymd}
  mv ${file}.1 ${file_name}
  xz -z ${file_name}
  openssl enc -e -aes-256-cbc -in ${file_name}.xz -out ${file_name}.xz.enc -k ${file_name}X*
  mv -f ${file_name}.xz.enc /var/box/$(hostname)/
  rm -f ${file_name}.xz
done
