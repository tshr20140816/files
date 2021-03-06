#!/bin/bash

export TZ=JST-9

set -x

if [ $# -ne 5 ]; then
    exit
fi

target_uuid=${1}
target_app=${2}
target_version=${3}
make_server=${4}
build_password=${5}

echo "$(date +%Y/%m/%d" "%H:%M:%S) start $(basename "${0}") ${target_app}"

wget --post-data="uuid=${target_uuid}&app=${target_app}&version=${target_version}&password=${build_password}" \
 https://${make_server}/make_${target_app}.php -O -

sleep 60s

file_name=${target_uuid}_maked_${target_app}-${target_version}.tar.xz
url=https://${make_server}/${file_name}
while :
do
    if [ $(wget -nv --spider --timeout 60 -t 1 ${url} 2>&1 | grep -c '200 OK') -eq 1 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) ${target_app} maked wget"
        break
    else
        echo "$(date +%Y/%m/%d" "%H:%M:%S) ${target_app} maked waiting"
        sleep 10s
    fi
done
pushd ${OPENSHIFT_TMP_DIR} >/dev/null
rm -f ${file_name}
wget ${url}
mv ${file_name} ${OPENSHIFT_DATA_DIR}/files/
popd >/dev/null

echo "$(date +%Y/%m/%d" "%H:%M:%S) finish $(basename "${0}") ${target_app}"
