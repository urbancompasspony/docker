#!/bin/bash

# rsyslog => log
/usr/sbin/rsyslogd &

# ACTIVE DIRECTORY
/init.sh setup &

# CUPS SERVER
/cups.sh &

# Block container exit
tail -f /dev/null
