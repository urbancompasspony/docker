#!/bin/bash

datetime=$(date +"%d/%m %H:%M")

function init {
  touch /var/log/date
  chmod 777 /var/log/date
  echo "$datetime" >> /var/log/date
}

init

exit 1
