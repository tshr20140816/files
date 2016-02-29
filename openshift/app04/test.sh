#!/bin/bash

echo "0913"

set -x

cd /tmp

cat << '__HEREDOC__' > test2016029.txt
__PROJECT_DB_MYSQL_HOST__
__HEREDOC__

perl -pi -e 's/__PROJECT_DB_MYSQL_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' test2016029.txt

cat test2016029.txt

exit
