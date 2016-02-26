#!/bin/bash

echo "1423"

set -x

word="admin"
abc=$(echo -n ${word}  | openssl sha1 | awk '{print $2;}')
echo $abc

exit
