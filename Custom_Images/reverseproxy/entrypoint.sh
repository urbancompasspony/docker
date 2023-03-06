#!/bin/bash

# Cron
echo "00 01 01 * * certbot --apache renew >> /var/log/cron.log 2>&1
# This extra line makes it a valid cron" > scheduler.txt
crontab scheduler.txt

# Deploy Certs
/script.sh &

# Apache2
/usr/sbin/apachectl start &

# Cron as a Service
/usr/sbin/cron -f &

# Keep container running!
tail -f /dev/null
