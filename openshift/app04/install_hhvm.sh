#!/bin/bash

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

# apache

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -nc -q http://ftp.kddilabs.jp/infosystems/apache//httpd/httpd-2.2.31.tar.bz2
tar jxf httpd-2.2.31.tar.bz2
pushd httpd-2.2.31 > /dev/null
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/apache --enable-mods-shared='all proxy'
time make -j4
make install
popd > /dev/null
rm -rf httpd-2.2.31
popd > /dev/null
quota -s

# fastcgi

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
# wget -nc -q http://www.fastcgi.com/dist/mod_fastcgi-current.tar.gz
wget -nc -q https://www.pccc.com/downloads/apache/current/mod_fastcgi-current.tar.gz
tar zxf mod_fastcgi-current.tar.gz
pushd mod_fastcgi-2.4.6 > /dev/null
time make top_dir=${OPENSHIFT_DATA_DIR}/apache
make install top_dir=${OPENSHIFT_DATA_DIR}/apache
popd > /dev/null
rm -rf mod_fastcgi-2.4.6
popd > /dev/null
quota -s

# boost

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -nc -q http://heanet.dl.sourceforge.net/project/boost/boost/1.54.0/boost_1_54_0.tar.bz2
tar jxf boost_1_54_0.tar.bz2
pushd boost_1_54_0 > /dev/null
export HOME=${OPENSHIFT_DATA_DIR}
cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/user-config.jam
using gcc : : gcc : <cflags>"-O2 -march=native -fomit-frame-pointer -s -pipe" <cxxflags>"-O2 -march=native -fomit-frame-pointer -s -pipe" ;
__HEREDOC__
./bootstrap.sh
./b2 --help
time ./b2 install -j1 --prefix=${OPENSHIFT_DATA_DIR}/boost \
 --libdir=${OPENSHIFT_DATA_DIR}/usr/lib \
 --link=shared \
 --runtime-link=shared \
 --without-atomic \
 --without-chrono \
 --without-context \
 --without-coroutine \
 --without-date_time \
 --without-exception \
 --without-graph \
 --without-graph_parallel \
 --without-iostreams \
 --without-locale \
 --without-log \
 --without-math \
 --without-mpi \
 --without-python \
 --without-random \
 --without-serialization \
 --without-signals \
 --without-test \
 --without-timer \
 --without-wave
popd > /dev/null
rm -rf boost_1_54_0
popd > /dev/null
rm -rf ${OPENSHIFT_DATA_DIR}/boost
quota -s

tree -a ${OPENSHIFT_DATA_DIR}/usr/lib

# oniguruma

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
mkdir src
pushd src > /dev/null
wget -nc -q http://vault.centos.org/6.7/os/Source/SPackages/oniguruma-5.9.1-3.1.el6.src.rpm
rpm2cpio oniguruma-5.9.1-3.1.el6.src.rpm | cpio -idmv
tar zxf onig-5.9.1.tar.gz
pushd onig-5.9.1 > /dev/null
./configure --help
./configure --prefix=${OPENSHIFT_TMP_DIR}/gomi --libdir=${OPENSHIFT_DATA_DIR}/usr/lib --enable-static=no
time make -j4
make install
popd > /dev/null
popd > /dev/null
rm -rf gomi src
popd > /dev/null

# inotify-tools

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
mkdir src
pushd src > /dev/null
wget -nc -q http://download.fedoraproject.org/pub/epel/6/SRPMS/inotify-tools-3.14-1.el6.src.rpm
rpm2cpio inotify-tools-3.14-1.el6.src.rpm | cpio -idmv
tar zxf inotify-tools-3.14.tar.gz
pushd inotify-tools-3.14 > /dev/null
./configure --help
./configure --prefix=${OPENSHIFT_TMP_DIR}/gomi --libdir=${OPENSHIFT_DATA_DIR}/usr/lib --enable-static=no
time make -j4
make install
popd > /dev/null
popd > /dev/null
rm -rf gomi src
popd > /dev/null

# lcms2

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
mkdir src
pushd src > /dev/null
wget -nc -q http://download.fedoraproject.org/pub/epel/6/SRPMS/lcms2-2.7-3.el6.src.rpm
rpm2cpio lcms2-2.7-3.el6.src.rpm | cpio -idmv
tar zxf lcms2-2.7.tar.gz
pushd lcms2-2.7 > /dev/null
./configure --help
./configure --prefix=${OPENSHIFT_TMP_DIR}/gomi --libdir=${OPENSHIFT_DATA_DIR}/usr/lib --enable-static=no
time make -j4
make install
popd > /dev/null
popd > /dev/null
rm -rf gomi src
popd > /dev/null

# hhvm
 
pushd ${OPENSHIFT_DATA_DIR} > /dev/null
wget -nc -q https://yum.gleez.com/6/x86_64/hhvm-3.5.0-4.el6.x86_64.rpm

wget -nc -q http://mirror.centos.org/centos/6/os/x86_64/Packages/libvpx-1.3.0-5.el6_5.x86_64.rpm
wget -nc -q http://mirror.centos.org/centos/6/os/x86_64/Packages/tbb-2.2-3.20090809.el6.x86_64.rpm
# wget -nc -q http://mirror.centos.org/centos/6/os/x86_64/Packages/oniguruma-5.9.1-3.1.el6.x86_64.rpm

# wget -nc -q http://dl.fedoraproject.org/pub/epel/6/x86_64/inotify-tools-3.14-1.el6.x86_64.rpm
wget -nc -q http://dl.fedoraproject.org/pub/epel/6/x86_64/libdwarf-20140413-1.el6.x86_64.rpm
wget -nc -q http://dl.fedoraproject.org/pub/epel/6/x86_64/libwebp-0.4.3-3.el6.x86_64.rpm
# wget -nc -q http://dl.fedoraproject.org/pub/epel/6/x86_64/lcms2-2.7-3.el6.x86_64.rpm

find ./ -name "*.rpm" -print > list.txt

while read -r LINE
do
    rpm2cpio ${LINE} | cpio -idmv
    rm -f ${LINE}
done < list.txt
rm -f list.txt

pushd usr/lib64 > /dev/null
ln -s /usr/lib64/mysql/libmysqlclient.so.16.0.0 libmysqlclient.so.18
ln -s libwebp.so.5.0.3 libwebp.so.4
popd > /dev/null
popd > /dev/null
rm -rf ${OPENSHIFT_DATA_DIR}/usr/share/doc/
rm -rf ${OPENSHIFT_DATA_DIR}/usr/share/man/
rm -rf ${OPENSHIFT_DATA_DIR}/usr/share/hhvm/LICENSE/

export LD_LIBRARY_PATH=${OPENSHIFT_DATA_DIR}/usr/lib:${OPENSHIFT_DATA_DIR}/usr/lib/hhvm:${OPENSHIFT_DATA_DIR}/usr/lib64
${OPENSHIFT_DATA_DIR}/usr/bin/hhvm --version

cat ${OPENSHIFT_DATA_DIR}/etc/hhvm/server.ini
quota -s

