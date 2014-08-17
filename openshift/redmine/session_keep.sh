#!/bin/bash

http_status=`curl -LI --digest -u user:bakayoke https://${OPENSHIFT_GEAR_DNS}/redmine/ -o /dev/null -s -w '%{http_code}\n'`
echo http_status $http_status

