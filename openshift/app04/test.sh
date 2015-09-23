#!/bin/bash

echo "1547"

set -x

quota -s

cd /tmp

rm test.php
wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app04/test.php
cat test.php

php test.php

rm test.php

exit

