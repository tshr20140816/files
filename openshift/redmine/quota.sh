#!/bin/bash

dt=`TZ=JST-9 date +%Y/%m/%d' '%R' '%Z`
cpu_usage=`mpstat | grep ^[0-9] | grep -v CPU | awk '{print $4}'`
echo cpu_usage $cpu_usage

quota | grep -v a | \
awk -v dt="$dt" -v cpu_usage="$cpu_usage" '{print "<root>\
<quota disk_use=\047" $1 \
"\047 disk_limit=\047" $3 \
"\047 disk_usage=\047" $1/$3*100 \
"\047 file_count=\047" $4 \
"\047 file_limit_count=\047" $6 \
"\047 file_usage=\047" $4/$6*100 \
"\047 date=\047" dt \
"\047/>\
<system_info fqdn=\047" ENVIRON["OPENSHIFT_APP_DNS"] \
"\047 cpu_usage=\047" cpu_usage \
"\047/>\
</root>"}' > $OPENSHIFT_REPO_DIR/public/quota.xml
