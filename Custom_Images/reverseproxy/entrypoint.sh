#!/bin/bash

# Cron
echo "00 01 01 * * certbot --apache renew >> /var/log/cron.log 2>&1
# This extra line makes it a valid cron" > scheduler.txt
crontab scheduler.txt

# Cron as a service
cron -f

# Apache2
/usr/sbin/apachectl start &

# CustomScript
/script.sh &

# Block from exit
tail -f /dev/null
