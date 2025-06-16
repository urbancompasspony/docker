#!/bin/bash

# entrypoint.sh modificado para incluir Apache

# rsyslog => log
/usr/sbin/rsyslogd &

# ACTIVE DIRECTORY
/init.sh setup &

# CUPS SERVER
/cups.sh &

# APACHE SERVER com Samba CGI
/apache-start.sh &

# Block container exit
tail -f /dev/null
