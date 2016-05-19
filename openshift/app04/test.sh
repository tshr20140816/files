#!/bin/bash

echo "1656"

set -x

quota -s
oo-cgroup-read memory.failcnt
echo "$(oo-cgroup-read memory.usage_in_bytes)" | awk '{printf "%\047d\n", $0}'

# oo-cgroup-read all
# oo-cgroup-read report

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

/usr/bin/gear start --trace

cd /tmp
ls -lang
cd $OPENSHIFT_DATA_DIR
ls -lang

quota -s

# -----

cd /tmp
rm -rf ccache-3.2.5 ccache gomi
rm -f ccache-3.2.5.tar.xz
rm -rf nghttp2-1.10.0
rm -rf Python-2.7.11
rm -rf 20160519
rm -f gcc-c++-5.3.1-6.fc23.i686.rpm

cd $OPENSHIFT_DATA_DIR
rm -rf bin include lib lib64 libexec local sbin share usr
ls -lang

# -----

convert --help

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

cd /tmp

wget -nc -q http://mirrors.kernel.org/gnu/gmp/gmp-4.3.2.tar.bz2
tar xf gmp-4.3.2.tar.bz2
cd gmp-4.3.2
./configure --help
./configure --prefix=$OPENSHIFT_DATA_DIR/usr --disable-shared --enable-static \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j2
make install
cd /tmp
rm -rf gmp-4.3.2

cd /tmp
wget -nc -q http://mirrors.kernel.org/gnu/mpfr/mpfr-2.4.2.tar.xz
tar xf mpfr-2.4.2.tar.xz
cd mpfr-2.4.2
./configure --help
./configure --prefix=$OPENSHIFT_DATA_DIR/usr --disable-shared --enable-static --with-gmp=$OPENSHIFT_DATA_DIR/usr \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j2
make install
cd /tmp
rm -rf mpfr-2.4.2

cd /tmp
wget -nc -q http://mirrors.kernel.org/gnu/mpc/mpc-1.0.3.tar.gz
tar xf mpc-1.0.3.tar.gz
cd mpc-1.0.3
./configure --help
./configure --prefix=$OPENSHIFT_DATA_DIR/usr --with-gmp=$OPENSHIFT_DATA_DIR/usr --with-mpfr=$OPENSHIFT_DATA_DIR/usr \
 --infodir=/tmp/gomi --mandir=/tmp/gomi --docdir=/tmp/gomi
time make -j4
make install
cd /tmp
rm -rf mpc-1.0.3
rm -rf gomi

tree -a ${OPENSHIFT_DATA_DIR}/usr

cd ${OPENSHIFT_DATA_DIR}

wget -q -nc https://dl.fedoraproject.org/pub/fedora/linux/updates/23/x86_64/g/gcc-5.3.1-6.fc23.x86_64.rpm
wget -q -nc https://dl.fedoraproject.org/pub/fedora/linux/updates/23/x86_64/g/glibc-2.22-16.fc23.x86_64.rpm
wget -q -nc https://dl.fedoraproject.org/pub/fedora/linux/updates/23/x86_64/g/gcc-c++-5.3.1-6.fc23.x86_64.rpm
wget -q -nc https://dl.fedoraproject.org/pub/fedora/linux/updates/23/x86_64/c/cpp-5.3.1-6.fc23.x86_64.rpm
# wget -q -nc ftp://rpmfind.net/linux/fedora/linux/releases/23/Everything/x86_64/os/Packages/l/libmpc-1.0.2-4.fc23.i686.rpm

rpm2cpio gcc-5.3.1-6.fc23.x86_64.rpm | cpio -idmv
rpm2cpio glibc-2.22-16.fc23.x86_64.rpm | cpio -idmv
rpm2cpio gcc-c++-5.3.1-6.fc23.x86_64.rpm | cpio -idmv
rpm2cpio cpp-5.3.1-6.fc23.x86_64.rpm | cpio -idmv
# rpm2cpio libmpc-1.0.2-4.fc23.i686.rpm | cpio -idmv

rm -f *.rpm

./lib64/ld-linux-x86-64.so.2 --library-path ${OPENSHIFT_DATA_DIR}/lib64:${OPENSHIFT_DATA_DIR}/usr/lib64 ./usr/bin/gcc --version
./lib64/ld-linux-x86-64.so.2 --library-path ${OPENSHIFT_DATA_DIR}/lib64:${OPENSHIFT_DATA_DIR}/usr/lib64 ./usr/bin/cc1 --version
./lib64/ld-linux-x86-64.so.2 --library-path ${OPENSHIFT_DATA_DIR}/lib64:${OPENSHIFT_DATA_DIR}/usr/lib64 ./usr/bin/c++ --version
./lib64/ld-linux-x86-64.so.2 --library-path ${OPENSHIFT_DATA_DIR}/lib64:${OPENSHIFT_DATA_DIR}/usr/lib64 ./usr/bin/g++ --version

mkdir -p ${OPENSHIFT_DATA_DIR}/usr/local/bin
cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/usr/local/bin/gcc
#!/bin/bash

export TZ=JST-9
echo "$(date +%Y/%m/%d" "%H:%M:%S) $*" >> ${OPENSHIFT_LOG_DIR}/gcc.log
LD_LIBRARY_PATH=${OPENSHIFT_DATA_DIR}/usr/lib ${OPENSHIFT_DATA_DIR}/lib64/ld-linux-x86-64.so.2 --library-path ${OPENSHIFT_DATA_DIR}/lib64:${OPENSHIFT_DATA_DIR}/usr/lib64:${OPENSHIFT_DATA_DIR}/usr/lib ${OPENSHIFT_DATA_DIR}/usr/bin/gcc "$@"
__HEREDOC__
chmod +x ${OPENSHIFT_DATA_DIR}/usr/local/bin/gcc
cat ${OPENSHIFT_DATA_DIR}/usr/local/bin/gcc

rm -f ${OPENSHIFT_LOG_DIR}/gcc.log
export PATH=${OPENSHIFT_DATA_DIR}/usr/local/bin:${PATH}
cd /tmp
wget -q -nc https://www.samba.org/ftp/ccache/ccache-3.2.5.tar.xz
rm -rf ccache-3.2.5
tar xf ccache-3.2.5.tar.xz
cd ccache-3.2.5
./configure
time make
cat config.log
cat ${OPENSHIFT_LOG_DIR}/gcc.log

quota -s
echo "FINISH"
exit
