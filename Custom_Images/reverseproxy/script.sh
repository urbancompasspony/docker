#!/bin/bash

# Auto Deplay all existent certs
ls /etc/letsencrypt/live/ > /tmp/live

for i in $(cat /tmp/live)
  do
    certbot install --cert-name $i
  done

exit 1
