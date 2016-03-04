#!/bin/bash

pushd ${OPENSHIFT_TMP_DIR} > /dev/null

compiled_file=./$(basename ${1})
result_file=${compiled_file}.result.txt

time java -jar ./compiler.jar \
 --summary_detail_level 3 \
 --js ${1}
 --js_output_file ${compiled_file} \
 2> ${result_file}

if [ "$(cat ${result_file})" = "0 error(s), 0 warning(s)" ]; then
    echo "CHANGED ${1}"
    cp -f ${1} ${1}.$(date '+%Y%m%d')
    mv -f ./$(basename ${1}) ${1}
else
    echo "NOT CHANGED $(head -n1 ${result_file}) ${1}"
fi
rm -f ./$(basename ${1}).result.txt

popd > /dev/null
