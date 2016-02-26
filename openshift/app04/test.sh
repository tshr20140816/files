#!/bin/bash

set -x

abc=$(echo -n "admin"  | openssl sha1 | awk '{print $2;}')
echo $abc

exit
