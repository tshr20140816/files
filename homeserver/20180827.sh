#!/bin/bash

sudo apt-get -y clean > /dev/null
sudo apt-get -y autoclean > /dev/null
sudo apt-get update > /dev/null

df -mh > /tmp/mail.txt
apt-get -s upgrade >> /tmp/mail.txt

mail -s aaa
