#! /bin/sh

/etc/init.d/openfire start

# Block container exit
tail -f /dev/null
