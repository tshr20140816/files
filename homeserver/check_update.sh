#!/bin/bash

count=$(ps aux | grep -c update_daemon2)

if [ $count -eq 1 ]; then
  /usr/bin/php /var/www/80/ttrss/update_daemon2.php --tasks 2 --interval 80 2>&1 | /usr/bin/php /home/toshi/loggly_ttrss.php &
fi
