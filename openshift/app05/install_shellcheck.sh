#!/bin/bash

# cd /tmp
# wget https://github.com/tshr20140816/files/raw/master/openshift/app05/install_shellcheck.sh
# bash install_shellcheck.sh > $OPENSHIFT_LOG_DIR/install.txt 2>&1 &

set -x

export TZ=JST-9

echo "$(date +%Y/%m/%d" "%H:%M:%S) START"

# quota -s
# oo-cgroup-read memory.failcnt

# ***** log dir digest auth *****

pushd ${OPENSHIFT_LOG_DIR} > /dev/null

echo user:realm:$(echo -n user:realm:${OPENSHIFT_APP_NAME} | md5sum | cut -c 1-32) > ${OPENSHIFT_DATA_DIR}/.htpasswd
echo AuthType Digest > .htaccess
echo AuthUserFile ${OPENSHIFT_DATA_DIR}/.htpasswd >> .htaccess

cat << '__HEREDOC__' >> .htaccess
AuthName realm

require valid-user

<Files ~ "^.(htpasswd|htaccess)$">
    deny from all
</Files>

AddType "text/plain; charset=UTF-8" .log

AddDefaultCharset utf-8

# IndexOptions +FancyIndexing

# Force https
RewriteEngine on
RewriteCond %{HTTP:X-Forwarded-Proto} !https
RewriteRule .* https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
__HEREDOC__
popd > /dev/null

pushd ${OPENSHIFT_REPO_DIR} > /dev/null
ln -s ${OPENSHIFT_LOG_DIR} logs
popd > /dev/null

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

# ls -lang ${OPENSHIFT_LOG_DIR}
mkdir ${OPENSHIFT_DATA_DIR}/tmp

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
wget -nc -q https://gmplib.org/download/gmp/gmp-6.1.0.tar.xz
tar Jxf gmp-6.1.0.tar.xz
pushd gmp-6.1.0 > /dev/null
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/local --enable-static=no
time make -j4
make install
popd > /dev/null
rm -rf gmp-6.1.0
rm -f gmp-6.1.0.tar.xz
export LD_LIBRARY_PATH=${OPENSHIFT_DATA_DIR}/usr/lib
popd > /dev/null

mkdir ${OPENSHIFT_DATA_DIR}/haskell
pushd ${OPENSHIFT_DATA_DIR}/haskell > /dev/null
if [ ! -f ${OPENSHIFT_DATA_DIR}/haskell/usr/bin/cabal ]; then
    wget -nc -q http://www.accursoft.com/cartridges/network.tar.gz
    tar xfz network.tar.gz
fi
rm -f network.tar.gz
popd > /dev/null

# quota -s
# oo-cgroup-read memory.failcnt

# export LD_LIBRARY_PATH=${OPENSHIFT_DATA_DIR}/usr/lib64
export PATH=${PATH}:${OPENSHIFT_DATA_DIR}/haskell/usr/bin
export HOME=${OPENSHIFT_DATA_DIR}
export OPENSHIFT_HASKELL_DIR=${OPENSHIFT_DATA_DIR}/haskell

# cabal install --help
# ghc-pkg list
ghc-pkg recache

# quota -s
# oo-cgroup-read memory.failcnt

fallocate -l 100M ${OPENSHIFT_REPO_DIR}/100mb.dat

mkdir -p ${OPENSHIFT_DATA_DIR}/local/bin
cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/local/bin/gcc
#!/bin/bash

while :
do
    usage_in_bytes=$(oo-cgroup-read memory.usage_in_bytes)
    if [ "${usage_in_bytes}" -lt 500000000 ]; then
        break
    fi
    dt=$(date +%H%M%S)
    usage_in_bytes_format=$(echo "${usage_in_bytes}" | awk '{printf "%\047d\n", $0}')
    failcnt=$(oo-cgroup-read memory.failcnt | awk '{printf "%\047d\n", $0}')
    echo "$dt $usage_in_bytes_format $failcnt"
    # ps alx --sort -rss | head -n 3
    if [ "${usage_in_bytes}" -gt 500000000 ]; then
        pushd ${OPENSHIFT_TMP_DIR} > /dev/null
        # if [ $(find ./ -type f -mmin -3 -name execute -print | wc -l) -eq 0 ]; then
        #     # sumanu
        #     wget -q http://mirrors.kernel.org/gnu/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2
        #     rm -f gcc-5.3.0.tar.bz2
        #     touch execute
        # fi
        wget -q http://${OPENSHIFT_APP_DNS}/100mb.dat
        rm -f 100mb.dat
        popd > /dev/null
    fi
    sleep 60s
done

set -x
/usr/bin/gcc "$@"
__HEREDOC__
chmod +x ${OPENSHIFT_DATA_DIR}/local/bin/gcc

mv -f ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings.org ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings

package_list=()
package_list+=("hashable-1.2.4.0")
package_list+=("unordered-containers-0.2.7.0")
package_list+=("tagged-0.8.3")
package_list+=("semigroups-0.18.1")
package_list+=("random-1.1")
package_list+=("primitive-0.6.1.0")
package_list+=("tf-random-0.5")
package_list+=("QuickCheck-2.8.2")
package_list+=("mtl-2.2.1")
package_list+=("parsec-3.1.9")
package_list+=("regex-base-0.93.2")
package_list+=("regex-tdfa-1.2.1")
package_list+=("json-0.9.1")
package_list+=("ShellCheck-0.4.3")

for package in "${package_list[@]}"
do
    echo "$(date +%Y/%m/%d" "%H:%M:%S) ${package}"
    [ $(ghc-pkg list | grep -c ${package}) -ne 0 ] && continue
    pushd ${OPENSHIFT_DATA_DIR}/tmp > /dev/null
    rm -rf "${package}"
    wget -nc -q https://hackage.haskell.org/package/"${package}"/"${package}".tar.gz
    tar xfz "${package}".tar.gz
    pushd "${package}" > /dev/null
    if [ "${package}" = "ShellCheck-0.4.3" ]; then
        cabal install -j1 -v3 --disable-optimization --disable-documentation \
         --disable-tests --disable-coverage --disable-benchmarks --disable-library-for-ghci \
         --ghc-options="+RTS -N1 -M448m -RTS"
    elif [ "${package}" != "regex-tdfa-1.2.1" ]; then
        cabal install -j2 --disable-documentation -O2 \
         --enable-split-objs --disable-library-for-ghci --enable-executable-stripping --enable-library-stripping \
         --disable-tests --disable-coverage --disable-benchmarks
    else
        PATH_ORG="${PATH}"
        export PATH="${OPENSHIFT_DATA_DIR}/local/bin:${PATH}"
        if [ ! -f ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings.org ]; then
            cp ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings.org
            sed -i -e "s|/usr/bin/gcc|${OPENSHIFT_DATA_DIR}/local/bin/gcc|g" ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings
        fi
        # cat ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings
        # cabal install -j1 -v3 --disable-optimization --disable-documentation \
        #  --disable-tests --disable-coverage --disable-benchmarks --disable-library-for-ghci \
        #  --ghc-options="+RTS -N1 -M448m -RTS"
        cabal install -j1 --disable-documentation -O2 \
         --enable-split-objs --disable-library-for-ghci --enable-executable-stripping --enable-library-stripping \
         --disable-tests --disable-coverage --disable-benchmarks \
         --ghc-options="+RTS -N1 -M448m -RTS"
        export PATH="${PATH_ORG}"
        cp -f ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings.org ${OPENSHIFT_DATA_DIR}/haskell/usr/lib/ghc-7.10.3/settings
    fi
    popd > /dev/null
    rm -rf "${package}"
    rm -f "${package}".tar.gz
    popd > /dev/null
    # quota -s
    # oo-cgroup-read memory.failcnt
    [ $(ghc-pkg list | grep -c ${package}) -eq 0 ] && break
done

rm -f ${OPENSHIFT_REPO_DIR}/100mb.dat

${OPENSHIFT_DATA_DIR}/.cabal/bin/shellcheck "${0}"

cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/local/bin/shellcheck
#!/bin/bash

export TZ=JST-9

export LD_LIBRARY_PATH=${OPENSHIFT_DATA_DIR}/usr/lib
export PATH=${PATH}:${OPENSHIFT_DATA_DIR}/haskell/usr/bin
export HOME=${OPENSHIFT_DATA_DIR}
export OPENSHIFT_HASKELL_DIR=${OPENSHIFT_DATA_DIR}/haskell

${OPENSHIFT_DATA_DIR}/.cabal/bin/shellcheck "$@"
__HEREDOC__
chmod +x ${OPENSHIFT_DATA_DIR}/local/bin/shellcheck

cat << '__HEREDOC__' > ${OPENSHIFT_REPO_DIR}/shellcheck.php
<?php
date_default_timezone_set('Asia/Tokyo');
$log_file = getenv("OPENSHIFT_LOG_DIR") . basename($_SERVER["SCRIPT_NAME"]) . "." . date("Ymd") . ".log";

if (!isset($_POST['suffix']))
{
    file_put_contents($log_file, date("YmdHis") . " CHECK POINT 010 suffix\n", FILE_APPEND);
    header('HTTP', true, 500);
    exit;
}
$suffix = $_POST["suffix"];
if (preg_match('/^\w+$/', $suffix) == 0)
{
    file_put_contents($log_file, date("YmdHis") . " CHECK POINT 020 $suffix\n", FILE_APPEND);
    header('HTTP', true, 500);
    exit;
}

if (!isset($_FILES['file']['error']) || !is_int($_FILES['file']['error']))
{
    file_put_contents($log_file, date("YmdHis") . " CHECK POINT 030 file\n", FILE_APPEND);
    header('HTTP', true, 500);
    exit;
}

if ($_FILES['upfile']['error'] != UPLOAD_ERR_OK)
{
    file_put_contents($log_file, date("YmdHis") . " CHECK POINT 040 file\n", FILE_APPEND);
    header('HTTP', true, 500);
    exit;
}

$file_name = $_FILES['file']['name'];
$original_file = getenv("OPENSHIFT_TMP_DIR") . $file_name . "." . $suffix;
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 050 suffix $suffix\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 060 file_name $file_name\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 070 original_file $original_file\n", FILE_APPEND);
move_uploaded_file($_FILES['file']['tmp_name'], $original_file);
chdir(getenv("OPENSHIFT_TMP_DIR"));
$cmd = getenv("OPENSHIFT_DATA_DIR") . "/.cabal/bin/shellcheck $original_file 2>&1";
exec($cmd, $arr, $res);
$tmp = var_dump($arr);
file_put_contents($log_file, date("YmdHis") . " RESULT $tmp\n", FILE_APPEND);
echo $tmp;
@unlink($original_file);
?>
__HEREDOC__

# ***** cron minutely *****

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null
rm -f ./*
touch jobs.deny

# *** index.html ***

cat << '__HEREDOC__' > make_index.sh
#!/bin/bash

export TZ=JST-9

pushd ${OPENSHIFT_LOG_DIR} > /dev/null
echo "<HTML><BODY><PRE>" > ${OPENSHIFT_TMP_DIR}/index.html
ls -lang >> ${OPENSHIFT_TMP_DIR}/index.html
quota -s >> ${OPENSHIFT_TMP_DIR}/index.html
echo "</PRE></BODY></HTML>" >> ${OPENSHIFT_TMP_DIR}/index.html
mv -f ${OPENSHIFT_TMP_DIR}/index.html ./
popd > /dev/null
__HEREDOC__
chmod +x make_index.sh
echo make_index.sh >> jobs.allow
popd > /dev/null

echo "$(date +%Y/%m/%d" "%H:%M:%S) FINISH"
