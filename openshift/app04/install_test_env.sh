#!/bin/bash

# rhc app create xxx php-5.4 cron-1.4 --server openshift.redhat.com

[ $# -ne 2 ] && exit

export TZ=JST-9

url=${1}
bash_script_file=${2}

cd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely

rm -f ./*
touch jobs.deny

cat << '__HEREDOC__' > exec_bash_script.sh
#!/bin/bash

# 5min wait
last_run=${OPENSHIFT_DATA_DIR}/cron_minutely_last_run
[ ! -f ${last_run} ] && touch ${last_run}
[[ $(find ${last_run} -mmin +4) ]] || exit
touch ${last_run}

export TZ=JST-9

cd ${OPENSHIFT_DATA_DIR}
if [ -f ${bash_script_file} ]; then
    mv -f ${bash_script_file} ${bash_script_file}.old
else
    touch ${bash_script_file}.old
fi
wget ${url}${bash_script_file}
cmp ${bash_script_file} ${bash_script_file}.old
[ $? -eq 0 ] && exit

bash ${bash_script_file}
__HEREDOC__
chmod +x exec_bash_script.sh
echo exec_bash_script.sh >> jobs.allow
