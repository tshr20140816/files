#!/bin/bash

mysqldump \
--host=$OPENSHIFT_MYSQL_DB_HOST \
--port=$OPENSHIFT_MYSQL_DB_PORT \
--user=$OPENSHIFT_MYSQL_DB_USERNAME \
--password=$OPENSHIFT_MYSQL_DB_PASSWORD \
-x --all-databases --events | xz > $OPENSHIFT_DATA_DIR/mysql_dump_`date +%a`.xz

