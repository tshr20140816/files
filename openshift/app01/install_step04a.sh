#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** rhc *****

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
gem environment
gem install commander -v 4.2.1 --no-rdoc --no-ri --with-cflags=\"-O2 -pipe -march=native -fomit-frame-pointer -s\"
gem install rhc --no-rdoc --no-ri --with-cflags=\"-O2 -pipe -march=native -fomit-frame-pointer -s\"




touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename "${0}").ok
