#!/bin/bash

# rhc setup --server openshift.redhat.com --create-token -l mail_address -p password
# rhc app create xxx diy-0.1 --server openshift.redhat.com

nginx_version=1.6.3

pushd /tmp > /dev/null
wget http://nginx.org/download/nginx-${nginx_version}.tar.gz
tar xfz nginx-${nginx_version}.tar.gz
pushd cd nginx-${nginx_version} > /dev/null

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
cp start start.org
cat << '__HEREDOC__' > start
#!/bin/bash

${OPENSHIFT_DATA_DIR}/nginx/sbin/nginx
__HEREDOC__
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/nginx/html > .dev/null
mkdir ${OPENSHIFT_DATA_DIR}/files
ln -s ${OPENSHIFT_DATA_DIR}/files files
popd > /dev/null

/usr/bin/gear stop
/usr/bin/gear start
