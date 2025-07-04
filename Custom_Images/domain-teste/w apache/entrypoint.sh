#!/bin/bash

# rsyslog => log
/usr/sbin/rsyslogd &

# ACTIVE DIRECTORY
/init.sh setup &

# CUPS SERVER
/cups.sh &

# APACHE SERVER com Samba CGI
find /var/run/apache2/ -name "cgisock*" -exec unlink {} \; 2>/dev/null || true

service apache2 start &

if [ ! -S /var/run/apache2/cgisock ]; then
  service apache2 restart
  sleep 1
fi

# Block container exit
tail -f /dev/null
