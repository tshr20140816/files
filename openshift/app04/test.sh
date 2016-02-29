#!/bin/bash

echo "0907"

set -x

cd /tmp

echo -n __PROJECT_DB_MYSQL_HOST__ > test2016029.txt
perl -pi -e 's/__PROJECT_DB_MYSQL_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' test2016029.txt

cat test2016029.txt

exit
