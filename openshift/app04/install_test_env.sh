#!/bin/bash

# rhc app create xxx php-5.4 cron-1.4 --server openshift.redhat.com

set -x

[ $# -ne 2 ] && exit

pushd ${OPENSHIFT_TMP_DIR}
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
[[ $(find ${last_run} -mmin +2) ]] || exit
touch ${last_run}

export TZ=JST-9

cd ${OPENSHIFT_DATA_DIR}
if [ -f __BASH_SCRIPT_FILE__ ]; then
    mv -f __BASH_SCRIPT_FILE__ __BASH_SCRIPT_FILE__.old
else
    touch __BASH_SCRIPT_FILE__.old
fi
wget --no-cache --no-check-certificate __URL____BASH_SCRIPT_FILE__
cmp __BASH_SCRIPT_FILE__ __BASH_SCRIPT_FILE__.old
[ $? -eq 0 ] && exit

bash __BASH_SCRIPT_FILE__
__HEREDOC__
sed -i -e "s|__BASH_SCRIPT_FILE__|${bash_script_file}|g" exec_bash_script.sh
sed -i -e "s|__URL__|${url}|g" exec_bash_script.sh
chmod +x exec_bash_script.sh
echo exec_bash_script.sh >> jobs.allow

cd ${OPENSHIFT_LOG_DIR} 

echo user:realm:$(echo -n user:realm:${OPENSHIFT_APP_NAME} | md5sum | cut -c 1-32) > ${OPENSHIFT_DATA_DIR}/.htpasswd
echo AuthType Digest > .htaccess
echo AuthUserFile ${OPENSHIFT_DATA_DIR}/.htpasswd >> .htaccess

cat << '__HEREDOC__' >> .htaccess
AuthName realm

require valid-user

<Files ~ "^.(htpasswd|htaccess)$">
    deny from all
</Files>

RewriteEngine on
RewriteCond %{HTTP:X-Forwarded-Proto} !https
RewriteRule .* https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
__HEREDOC__

cd ${OPENSHIFT_REPO_DIR}
ln -s ${OPENSHIFT_LOG_DIR} logs
popd
