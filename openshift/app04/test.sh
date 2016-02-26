#!/bin/bash

echo "1659"

set -x

download_list=()
download_list[${#download_list[@]}]="spdy,mod-spdy-beta_current_x86_64.rpm,https://dl-ssl.google.com/dl/linux/direct/mod-spdy-beta_current_x86_64.rpm"
download_list[${#download_list[@]}]="rbenv-installer,rbenv-installer,https://raw.github.com/Seppone/openshift-rbenv-installer/master/bin/rbenv-installer"

for item in ${download_list[@]}
do
    echo "$item"
done

exit
