#!/bin/bash

# Cron
echo "00 01 01 * * certbot --apache renew >> /var/log/cron.log 2>&1
# This extra line makes it a valid cron" > scheduler.txt
crontab scheduler.txt

# CustomScript
/script.sh &

# Apache2
/usr/sbin/apachectl start &

# Cron as a service
/usr/sbin/cron -f &

# Block from exit
tail -f /dev/null
