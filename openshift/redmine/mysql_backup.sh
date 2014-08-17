#!/bin/bash

mysqldump \
-h $OPENSHIFT_MYSQL_DB_HOST:$OPENSHIFT_MYSQL_DB_PORT \
-u $OPENSHIFT_MYSQL_DB_USERNAME \
-p $OPENSHIFT_MYSQL_DB_PASSWORD \
-x --all-databases | gzip > $OPENSHIFT_DATA_DIR/mysql_dump_`date +%a`.gz

