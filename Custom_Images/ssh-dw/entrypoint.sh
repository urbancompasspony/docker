#!/bin/bash

# SSH
/usr/sbin/sshd &

# DWService
/bin/sh /usr/share/dwagent/native/dwagsvc run &

# Keep container running!
tail -f /dev/null
