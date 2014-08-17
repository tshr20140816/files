#!/bin/bash

http_status=`curl -LI http://${OPENSHIFT_GEAR_DNS}/ -o /dev/null -w '%{http_code}\n' -s`
echo http_status $http_status
if test $http_status -eq 503 ; then
    echo ctl_all restart
    ctl_all restart
fi

