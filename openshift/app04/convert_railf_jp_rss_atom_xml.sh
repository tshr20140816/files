#!/bin/bash

cd /tmp
rm atom.xml
wget http://railf.jp/rss/atom.xml
sed -i -e "s|&mdash;|-|g" atom.xml
cp -f atom.xml ${OPENSHIFT_DATA_DIR}/apache/htdocs/railf_jp_rss_atom.xml
