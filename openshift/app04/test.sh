#!/bin/bash

# 1015

set -x

quota -s

cd /tmp

cat << '__HEREDOC__' > squid.conf
acl myhost src __OPENSHIFT_PHP_IP__/32

acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 443
acl CONNECT method CONNECT
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports

http_access allow myhost manager
http_access deny manager

http_access allow myhost

http_access deny all

http_port 33128

dns_nameservers 8.8.8.8

udp_incoming_address __OPENSHIFT_PHP_IP__

cache_dir ufs /var/lib/openshift/554b6b37e0b8cda2a300005d/app-root/data//squid/var/cache/squid 100 16 256
coredump_dir /var/lib/openshift/554b6b37e0b8cda2a300005d/app-root/data//squid/var/cache/squid

refresh_pattern ^ftp:		1440	20%	10080
refresh_pattern ^gopher:	1440	0%	1440
refresh_pattern -i (/cgi-bin/|\?) 0	0%	0
refresh_pattern .		0	20%	4320

__HEREDOC__
sed -i -e "s|__OPENSHIFT_PHP_IP__|${OPENSHIFT_PHP_IP}|g" squid.conf
cat squid.conf

ls -lang ${OPENSHIFT_DATA_DIR}/squid/var/run/
tree ${OPENSHIFT_DATA_DIR}/squid/var/run/
ps ax | grep squid
tree ${OPENSHIFT_DATA_DIR}/squid/var/logs/
${OPENSHIFT_DATA_DIR}/squid/sbin/squid -h
cat /var/lib/openshift/554b6b37e0b8cda2a300005d/app-root/data//squid/var/logs/cache.log
rm /var/lib/openshift/554b6b37e0b8cda2a300005d/app-root/data//squid/var/logs/cache.log
# ${OPENSHIFT_DATA_DIR}/squid/sbin/squid -a 33128 -k restart 2>&1
${OPENSHIFT_DATA_DIR}/squid/sbin/squid -kparse -f/tmp/squid.conf
${OPENSHIFT_DATA_DIR}/squid/sbin/squid -f/tmp/squid.conf
cat /var/lib/openshift/554b6b37e0b8cda2a300005d/app-root/data//squid/var/logs/cache.log

curl --proxy http://${OPENSHIFT_PHP_IP}:33128 http://www.google.com

cat /var/lib/openshift/554b6b37e0b8cda2a300005d/app-root/data//squid/var/logs/cache.log

tree ${OPENSHIFT_DATA_DIR}/squid/var/run/
${OPENSHIFT_DATA_DIR}/squid/sbin/squid -kshutdown

cat /var/lib/openshift/554b6b37e0b8cda2a300005d/app-root/data//squid/var/logs/cache.log
