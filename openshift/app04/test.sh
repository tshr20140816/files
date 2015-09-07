#!/bin/bash

set -x

quota -s

cd /tmp

sphinx_version=2.2.9
# wget http://sphinxsearch.com/files/sphinx-${sphinx_version}-release.tar.gz
# tar zxf sphinx-${sphinx_version}-release.tar.gz

# ls -lang

cd sphinx-${sphinx_version}-release
./configure --help
./configure \
     --prefix=${OPENSHIFT_DATA_DIR}/sphinx \
     --mandir=/tmp/gomi \
     --infodir=/tmp/gomi \
     --docdir=/tmp/gomi \
     --disable-dependency-tracking \
     --disable-id64 \
     --with-mysql \
     --without-syslog
