#!/bin/sh

/SMS/bin/powerview start -g --no-debug &

# Block container exit
tail -f /dev/null
