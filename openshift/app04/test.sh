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
./configure
