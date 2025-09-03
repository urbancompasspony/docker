#!/bin/bash

if [ -f /run/rsyslogd.pid ]; then
    OLD_PID=$(cat /run/rsyslogd.pid)
    if kill -0 $OLD_PID 2>/dev/null; then
        echo "Matando rsyslogd anterior (PID: $OLD_PID)"
        kill $OLD_PID
        sleep 2
    fi
    rm -f /run/rsyslogd.pid
fi

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
