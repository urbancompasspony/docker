#!/bin/bash

# DWService
/bin/sh /usr/share/dwagent/native/dwagsvc run &
sleep 10
/bin/sh /usr/share/dwagent/native/dwagsvc run

# AutoMount
/script.sh &

# Keep container running!
tail -f /dev/null
