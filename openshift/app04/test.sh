#!/bin/bash

echo "1012"

# set -x

cd /tmp

rm -rf graphviz-2.38.0
rm mod-spdy-beta_current_x86_64.rpm
rm rbenv-installer

ls -lang

cat << '__HEREDOC__' > test2016029.txt
__PROJECT_DB_MYSQL_HOST__
__HEREDOC__

perl -pi -e 's/__PROJECT_DB_MYSQL_HOST__/$ENV{OPENSHIFT_GEAR_UUID}/g' test2016029.txt

cat test2016029.txt

exit
