#!/bin/bash

# DWService
/bin/sh /usr/share/dwagent/dw/native/dwagsvc run &

# AutoMount
/script.sh &

# Keep container running!
tail -f /dev/null
