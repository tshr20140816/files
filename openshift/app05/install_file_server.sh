#!/bin/bash

# rhc setup --server openshift.redhat.com --create-token -l mail_address -p password
# rhc app create xxx diy-0.1 cron-1.4 --server openshift.redhat.com

export TZ=JST-9

nginx_version=1.6.3

pushd /tmp > /dev/null
wget http://nginx.org/download/nginx-${nginx_version}.tar.gz
tar xfz nginx-${nginx_version}.tar.gz
pushd nginx-${nginx_version} > /dev/null

CFLAGS="-O2 -march=native -pipe" CXXFLAGS="-O2 -march=native -pipe" \
 ./configure --prefix=${OPENSHIFT_DATA_DIR}/nginx \
 --without-select_module \
 --without-poll_module \
 --without-http_charset_module \
 --without-http_gzip_module \
 --without-http_ssi_module \
 --without-http_userid_module \
 --without-http_access_module \
 --without-http_auth_basic_module \
 --without-http_geo_module \
 --without-http_map_module \
 --without-http_split_clients_module \
 --without-http_referer_module \
 --without-http_rewrite_module \
 --without-http_proxy_module \
 --without-http_fastcgi_module \
 --without-http_uwsgi_module \
 --without-http_scgi_module \
 --without-http_memcached_module \
 --without-http_limit_conn_module \
 --without-http_limit_req_module \
 --without-http_empty_gif_module \
 --without-http_browser_module \
 --without-http_upstream_ip_hash_module \
 --without-http_upstream_least_conn_module \
 --without-http_upstream_keepalive_module \
 --without-http-cache \
 --without-mail_pop3_module \
 --without-mail_imap_module \
 --without-mail_smtp_module \
 --without-pcre

time make -j$(grep -c -e processor /proc/cpuinfo)
make install

perl -pi -e 's/^(\s+)(listen\s+)80;/$1$2$ENV{OPENSHIFT_DIY_IP}:8080;\n$1autoindex on;/g' \
${OPENSHIFT_DATA_DIR}/nginx/conf/nginx.conf

popd > /dev/null
popd > /dev/null

pushd ${OPENSHIFT_REPO_DIR}/.openshift/action_hooks/ > /dev/null
cp start start.$(date '+%Y%m%d')
cat << '__HEREDOC__' > start
#!/bin/bash

export TZ=JST-9

testrubyserver_count=$(ps aux | grep -e testrubyserver.rb | grep -e ${OPENSHIFT_APP_UUID} | grep -c -v grep)
if [ ${testrubyserver_count} -gt 0 ]; then
    kill $(ps auwx 2>/dev/null | grep -e testrubyserver.rb | grep -e ${OPENSHIFT_APP_UUID} | grep -v grep | awk '{print $2}')
fi
${OPENSHIFT_DATA_DIR}/nginx/sbin/nginx -s stop
${OPENSHIFT_DATA_DIR}/nginx/sbin/nginx
__HEREDOC__
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/nginx/html > .dev/null
mkdir ${OPENSHIFT_DATA_DIR}/files
ln -s ${OPENSHIFT_DATA_DIR}/files files
popd > /dev/null

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/daily > /dev/null
rm -f ./*
touch jobs.deny

# *** gem ***

cat << '__HEREDOC__' > gem.sh
#!/bin/bash

export TZ=JST-9
pushd ${OPENSHIFT_DATA_DIR}/files/ > /dev/null

for gem in bundler rack passenger
do
    rm -f ${gem}.html
    wget https://rubygems.org/gems/${gem} -O ${gem}.html
    version=$(grep -e canonical ${gem}.html | sed -r -e 's|^.*versions/(.+)".*$|\1|g')
    if [ ! -f ${gem}-${version}.gem ]; then
        wget https://rubygems.org/downloads/${gem}-${version}.gem -O ${gem}-${version}.gem
        perl -pi -e 's/(\r|\n)//g' ${gem}.html
        perl -pi -e 's/.*gem__sha"> +//g' ${gem}.html
        perl -pi -e 's/ +<.*//g' ${gem}.html
        gem_sha256=$(cat ${gem}.html)
        file_sha256=$(sha256sum ${gem}-${version}.gem | cut -d ' ' -f 1)
        if [ "${gem_sha256}" != "${file_sha256}" ]; then
            rm ${gem}-${version}.gem
        fi
    fi
    rm -f ${gem}.html
done
popd > /dev/null
__HEREDOC__
chmod +x gem.sh
echo gem.sh >> jobs.allow
./gem.sh

# https://github.com/tshr20140816/files/raw/master/openshift/app05/download_file_list.txt
# *** download_file_list ***

cat << '__HEREDOC__' > download_file_list.sh
#!/bin/bash

export TZ=JST-9
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -f download_file_list.txt
wget https://github.com/tshr20140816/files/raw/master/openshift/app05/download_file_list.txt
while read LINE
do
    file_name=$(echo "${LINE}" | awk '{print $1}')
    if [ ! -t ${OPENSHIFT_DATA_DIR}/files/${file_name} ]; then
        url=$(echo "${LINE}" | awk '{print $2}')
        rm -f ${file_name}
        wget ${url} -O ${file_name}
        mv -f ${file_name} ${OPENSHIFT_DATA_DIR}/files/
    fi
done < download_file_list.txt
popd > /dev/null
__HEREDOC__
chmod +x download_file_list.sh
echo download_file_list.sh >> jobs.allow
./download_file_list.sh

popd > /dev/null

/usr/bin/gear stop
/usr/bin/gear start
