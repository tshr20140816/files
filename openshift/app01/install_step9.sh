#!/bin/bash

set -x

while read LINE
do
  product=`echo $LINE | awk '{print $1}'`
  version=`echo $LINE | awk '{print $2}'`
  eval "$product"=$version
done < ${OPENSHIFT_TMP_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 9 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** mrtg *****

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/mrtg-${mrtg_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` mrtg tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz mrtg-${mrtg_version}.tar.gz
cd mrtg-${mrtg_version}
echo `date +%Y/%m/%d" "%H:%M:%S` mrtg configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure --prefix=${OPENSHIFT_DATA_DIR}/mrtg 2>&1 | tee ${OPENSHIFT_LOG_DIR}/mrtg.configure.log
echo `date +%Y/%m/%d" "%H:%M:%S` mrtg make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j2
echo `date +%Y/%m/%d" "%H:%M:%S` mrtg make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
mkdir ${OPENSHIFT_DATA_DIR}/mrtg/workdir
mkdir ${OPENSHIFT_DATA_DIR}/mrtg/scripts
cd ${OPENSHIFT_DATA_DIR}/mrtg

touch scripts/cpu_usage.sh
cat << '__HEREDOC__' > scripts/cpu_usage.sh
#!/bin/bash

echo `cat ${OPENSHIFT_TMP_DIR}/cpu_usage_current`
echo 0
echo dummy
echo cpu usage
__HEREDOC__
chmod +x scripts/cpu_usage.sh

touch scripts/disk_usage.sh
cat << '__HEREDOC__' > scripts/disk_usage.sh
#!/bin/bash

echo `quota | grep -v a | awk '{print $1}'`
echo `quota | grep -v a | awk '{print $3}'`
echo dummy
echo disk usage
__HEREDOC__
chmod +x scripts/disk_usage.sh

touch scripts/file_usage.sh
cat << '__HEREDOC__' > scripts/file_usage.sh
#!/bin/bash

echo `quota | grep -v a | awk '{print $4}'`
echo `quota | grep -v a | awk '{print $6}'`
echo dummy
echo file usage
__HEREDOC__
chmod +x scripts/file_usage.sh

touch scripts/memory_usage.sh
cat << '__HEREDOC__' > scripts/memory_usage.sh
#!/bin/bash

echo `oo-cgroup-read memory.usage_in_bytes | awk '{print $1}'`
echo `oo-cgroup-read memory.limit_in_bytes | awk '{print $1}'`
echo dummy
echo memory usage
__HEREDOC__
chmod +x scripts/memory_usage.sh

cat << '__HEREDOC__' > mrtg.conf
WorkDir: __OPENSHIFT_DATA_DIR__mrtg/www/
HtmlDir: __OPENSHIFT_DATA_DIR__mrtg/www/
ImageDir: __OPENSHIFT_DATA_DIR__mrtg/www/
LogDir: __OPENSHIFT_DATA_DIR__mrtg/log/
Refresh: 60000

Target[disk]: `${OPENSHIFT_DATA_DIR}/mrtg/scripts/disk_usage.sh`
Title[disk]: Disk
PageTop[disk]: <h1>Disk</h1>
Options[disk]: gauge, nobanner, growright, unknaszero, noinfo
AbsMax[disk]: 10000000
MaxBytes[disk]: 1048576
kilo[disk]: 1024
YLegend[disk]: Disk Use
LegendI[disk]: Use
LegendO[disk]: Limit
Legend1[disk]: Disk Use
Legend2[disk]: Disk Limit
ShortLegend[disk]: B
Suppress[disk]: y
Factor[disk]: 1024
YTicsFactor[disk]: 1024

Target[file]: `${OPENSHIFT_DATA_DIR}/mrtg/scripts/file_usage.sh`
Title[file]: Files
PageTop[file]: <h1>Files</h1>
Options[file]: gauge, nobanner, growright, unknaszero, noinfo, integer
AbsMax[file]: 1000000
MaxBytes[file]: 80000
YLegend[file]: File Count
LegendI[file]: Files
LegendO[file]: Limit
Legend1[file]: File Count
Legend2[file]: File Count Limit
ShortLegend[file]: files
Suppress[file]: y

Target[memory]: `${OPENSHIFT_DATA_DIR}/mrtg/scripts/memory_usage.sh`
Title[memory]: Memory
PageTop[memory]: <h1>Memory</h1>
Options[memory]: gauge, nobanner, growright, unknaszero, noinfo
AbsMax[memory]: 5368709120
MaxBytes[memory]: 536870912
YLegend[memory]: Memory Use
LegendI[memory]: Use
LegendO[memory]: Limit
Legend1[memory]: Memory Use
Legend2[memory]: Memory Limit
ShortLegend[memory]: B
Suppress[memory]: y

Target[cpu]: `${OPENSHIFT_DATA_DIR}/mrtg/scripts/cpu_usage.sh`
Title[cpu]: Cpu
PageTop[cpu]: <h1>Cpu</h1>
Options[cpu]: gauge, nobanner, growright, unknaszero, noinfo, noo
AbsMax[cpu]: 200
MaxBytes[cpu]: 100
YLegend[cpu]: Cpu Usage
LegendI[cpu]: Usage
Legend1[cpu]: Cpu Usage
ShortLegend[cpu]: %
Suppress[cpu]: y
WithPeak[cpu]: dwm
Unscaled[cpu]: dwm
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' mrtg.conf

mkdir ${OPENSHIFT_DATA_DIR}/mrtg/log
mkdir ${OPENSHIFT_DATA_DIR}/mrtg/www
cd ${OPENSHIFT_DATA_DIR}/mrtg
./bin/indexmaker --output=index.html mrtg.conf
cp index.html www/

cd ${OPENSHIFT_TMP_DIR}
rm mrtg-${mrtg_version}.tar.gz
rm -rf mrtg-${mrtg_version}

# *** apache link ***

ln -s ${OPENSHIFT_DATA_DIR}/mrtg/www ${OPENSHIFT_DATA_DIR}/apache/htdocs/mrtg

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 9 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
