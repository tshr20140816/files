#!/bin/bash

# 1414

set -x

cd /tmp

ls -lang ${OPENSHIFT_LOG_DIR}

cd ${OPENSHIFT_LOG_DIR}

rm cron_minutely.log-*
rm distcc*
rm php_*
rm ccache*

quota -s
