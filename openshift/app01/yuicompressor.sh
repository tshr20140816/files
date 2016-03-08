#!/bin/bash

export TZ=JST-9

echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ ${1}"
echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ $(oo-cgroup-read memory.usage_in_bytes | awk '{printf "%\047d\n", $1}')" \
 >> ${OPENSHIFT_LOG_DIR}/yuicompressor.log
while :
do
    usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
    if [ ${usage_in_bytes} -gt 450000000 ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ $(oo-cgroup-read memory.usage_in_bytes | awk '{printf "%\047d\n", $1}') waiting" \
         >> ${OPENSHIFT_LOG_DIR}/yuicompressor.log
        sleep 5s
    else
        break
    fi
done
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
suffix=$(date '+%Y%m%d')
target_file=${1}
compressed_file=./$(basename ${target_file}).$$
rm -f ${compressed_file}.$$
time java -jar ${OPENSHIFT_TMP_DIR}/yuicompressor.jar \
 --type css \
 -o ${compressed_file} \
 ${target_file} \
 >> ${OPENSHIFT_LOG_DIR}/yuicompressor.log 2>&1
if [ ! -f ${compressed_file} ]; then
    echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ NOT CHANGED (ERROR) ${target_file}" \
     >> ${OPENSHIFT_LOG_DIR}/yuicompressor.log
else
    size_original=$(wc -c < ${target_file})
    size_compiled=$(wc -c < ${compressed_file})
    if [ ${size_original} -gt ${size_compiled} ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ CHANGED ${size_original} ${size_compiled} ${target_file}" \
         >> ${OPENSHIFT_LOG_DIR}/yuicompressor.log
        mv -f ${target_file} ${target_file}.${suffix}
        mv -f ${compressed_file} ${target_file}
    else
        echo "$(date +%Y/%m/%d" "%H:%M:%S) $$ NOT CHANGED (SIZE NOT DOWNED) ${size_original} ${size_compiled} ${target_file}" \
         >> ${OPENSHIFT_LOG_DIR}/yuicompressor.log
        rm -f ${compressed_file}
    fi
fi
popd > /dev/null
