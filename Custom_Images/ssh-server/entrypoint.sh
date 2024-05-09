#!/bin/bash

# Some options to keep it clean
known_hosts_file="/home/$USER/.ssh/known_hosts"
scpoptions="-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=60 -o ServerAliveCountMax=5"

# Password pfSense
var1=$(sed -n '1p' /data/ssh)

# pfSense User
var2=$(sed -n '2p' /data/ssh)

# pfSense IP (Gateway)
var3=$(sed -n '3p' /data/ssh)

# New Port (default 2222)
var4=$(sed -n '4p' /data/ssh)

# Linux Server IP
var5=$(sed -n '5p' /data/ssh)

# Linux Server Port
var6=$(sed -n '6p' /data/ssh)

# Run key-gen to cleanup everything
ssh-keygen -f $known_hosts_file -R "$var3"

sshpass -p "$var1" ssh $scpoptions "$var2"@"$var3" -N -f -L "$var4":"$var5":"$var6"

# Keep container running!
tail -f /dev/null

exit 0
