#!/bin/bash

datetime=$(date +"%d/%m %H:%M")

function init {
  echo "$datetime" >> /var/log/date
}

init

exit 1
