#!/bin/bash

export TZ=JST-9

echo "$$ $(oo-cgroup-read memory.usage_in_bytes | awk '{printf "%\047d\n", $1}')" \
 >> ${OPENSHIFT_LOG_DIR}/closure_compiler.log
while :
do
    local usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
    if [ ${usage_in_bytes} -gt 350000000 ]; then
        echo "$$ $(oo-cgroup-read memory.usage_in_bytes | awk '{printf "%\047d\n", $1}') waiting" \
         >> ${OPENSHIFT_LOG_DIR}/closure_compiler.log
        sleep 5s
    else
        break
    fi
done
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
local suffix=$(date '+%Y%m%d')
local target_file=${1}
local compiled_file=./$(basename ${target_file}).$$
local result_file=${compiled_file}.result.txt.$$
rm -f ${compiled_file}.$$
rm -f ${result_file}.$$
time java -jar ${OPENSHIFT_DATA_DIR}/compiler.jar \
 --summary_detail_level 3 \
 --compilation_level SIMPLE_OPTIMIZATIONS \
 --js ${target_file} \
 --js_output_file ${compiled_file} \
 2> ${result_file}
if [ "$(cat ${result_file})" = "0 error(s), 0 warning(s)" ]; then
    local size_original=$(wc -c < ${target_file})
    local size_compiled=$(wc -c < ${compiled_file})
    if [ ${size_original} -gt ${size_compiled} ]; then
        echo "$(date +%Y/%m/%d" "%H:%M:%S) CHANGED ${size_original} ${size_compiled} ${target_file}" \
         >> ${OPENSHIFT_LOG_DIR}/closure_compiler.log
        cp -f ${target_file} ${target_file}.${suffix}
        mv -f ${compiled_file} ${target_file}
    else
        echo "$(date +%Y/%m/%d" "%H:%M:%S) NOT CHANGED (SIZE NOT DOWNED) ${size_original} ${size_compiled} ${target_file}" \
         >> ${OPENSHIFT_LOG_DIR}/closure_compiler.log
    fi
else
    echo "$(date +%Y/%m/%d" "%H:%M:%S) NOT CHANGED (ERROR OR WARNING) ${target_file} $(tail -n 1 ./${result_file})" \
     >> ${OPENSHIFT_LOG_DIR}/closure_compiler.log
    # cat ${result_file} >> ${OPENSHIFT_LOG_DIR}/closure_compiler.log
fi
rm -f ${compiled_file}
rm -f ${result_file}
popd > /dev/null
