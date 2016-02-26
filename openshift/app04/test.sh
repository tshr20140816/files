#!/bin/bash

set -x

abc=$(echo -n "admin"  | openssl sha1)
echo $abc

exit
