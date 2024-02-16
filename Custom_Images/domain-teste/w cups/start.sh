#!/bin/bash

# rsyslog => log
/usr/sbin/rsyslogd &

# ACTIVE DIRECTORY
/init.sh setup &

# CUPS SERVER
/entrypoint.sh &

# Block container exit
tail -f /dev/null
