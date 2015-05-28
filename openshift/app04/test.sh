#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

exit

cd /tmp

export HOME=$OPENSHIFT_DATA_DIR
cd .ssh
cat << '__HEREDOC__' > config
Host *
  IdentityFile __OPENSHIFT_DATA_DIR__.ssh/id_rsa
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel QUIET
#  LogLevel DEBUG3
  Protocol 2
  Ciphers arcfour
  PasswordAuthentication no
  ConnectionAttempts 5
  ControlMaster auto
  ControlPath /tmp/.ssh/master-%r@%h:%p
  ControlPersist 10s
__HEREDOC__
sed -i -e "s|__OPENSHIFT_DATA_DIR__|${OPENSHIFT_DATA_DIR}|g" config

# ssh -24n -F config 555781ad4382ece1eb00005e@b4-20150514.rhcloud.com ls -lang app-root/data/distcc/bin

# ssh -24MN -F config 55630afc5973caf283000214@v1-20150216.rhcloud.com &
# ssh -24MN -F config 55630b63e0b8cd7ed000007f@v2-20150216.rhcloud.com &
# ssh -24MN -F config 55630c675973caf283000251@v3-20150216.rhcloud.com &
# ssh -24MN -F config 555894314382ec8df40000e1@b1-20150430.rhcloud.com &
# ssh -24MN -F config 555895235973ca539500007e@b2-20150430.rhcloud.com &
# ssh -24MN -F config 555895dbfcf9337761000009@b3-20150430.rhcloud.com &
# ssh -24MN -F config 555f3483500446724c000127@b7-20150522.rhcloud.com &
# ssh -24MN -F config 555f387de0b8cd419e0000cc@b8-20150522.rhcloud.com &
# ssh -24MN -F config 555f34eae0b8cd8b2400001e@b9-20150522.rhcloud.com &
# ssh -24MN -F config 555781ad4382ece1eb00005e@b4-20150514.rhcloud.com &
# ssh -24MN -F config 555782f44382ecdc6d00003b@b5-20150514.rhcloud.com &
# ssh -24MN -F config 5557844c4382ecd6b00000f8@b6-20150514.rhcloud.com &
# ps auwx | grep ssh

date

ssh -24MN -F config 555894314382ec8df40000e1@b1-20150430.rhcloud.com

date

ps auwx | grep ssh
