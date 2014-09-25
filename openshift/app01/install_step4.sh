#!/bin/bash

#ctl_all stop
/usr/bin/gear stop

export GEM_HOME=${OPENSHIFT_DATA_DIR}.gem
export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH" 
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH" 
eval "$(rbenv init -)" 
export APXS2=${OPENSHIFT_DATA_DIR}/apache/bin/apxs
export PATH=${OPENSHIFT_DATA_DIR}/apache/bin:$PATH
export HTTPD=${OPENSHIFT_DATA_DIR}/apache/bin/httpd
export BINDIR=${OPENSHIFT_DATA_DIR}/apache

time CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
${OPENSHIFT_DATA_DIR}/.gem/bin/passenger-install-apache2-module --auto

ctl_all restart

