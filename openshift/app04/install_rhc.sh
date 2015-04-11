#!/bin/bash

# rhc app create xxx ruby-2.0 --server openshift.redhat.com

set -x

export TZ=JST-9

gem install commander -v 4.2.1
gem install rhc

cat << '__HEREDOC__'
export HOME=${OPENSHIFT_DATA_DIR}
rhc setup --server openshift.redhat.com --create-token -l mail_address -p password
__HEREDOC__
