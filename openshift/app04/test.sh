#!/bin/bash

echo "1531"

set -x

quota -s
oo-cgroup-read memory.failcnt
echo "$(oo-cgroup-read memory.usage_in_bytes)" | awk '{printf "%\047d\n", $0}'

# oo-cgroup-read all
# oo-cgroup-read report

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

/usr/bin/gear start --trace

cd /tmp
ls -lang
cd $OPENSHIFT_DATA_DIR
ls -lang

quota -s

# -----

cd /tmp
rm -rf 20160506
# rm -rf gomi build
# rm -rf ${OPENSHIFT_DATA_DIR}/usr

# -----

cat << '__HEREDOC__' > ${OPENSHIFT_REPO_DIR}/502.php
<html>
<head>
<?php
$referer = $_SERVER['HTTP_REFERER'];
echo "<meta http-equiv='refresh' content='10;URL=$referer'>";
?>
<title>502 Error</title>
</head>
<body>
<div><?php echo $_SERVER['HTTP_REFERER']; ?></div><br />
<div>Auto Retry...</div>
</body>
</html>
__HEREDOC__

ls -lang ${OPENSHIFT_REPO_DIR}

cd /tmp

mkdir 20160506
cd 20160506
wget -q https://files.phpmyadmin.net/phpMyAdmin/4.4.15.5/phpMyAdmin-4.4.15.5-english.tar.bz2
tar xf phpMyAdmin-4.4.15.5-english.tar.bz2
tree -a ./

quota -s
echo "FINISH"
exit
