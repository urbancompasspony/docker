#!/bin/bash

USERNAME="$1"
NOMESHARE="$2"

[ "$EUID" -ne 0 ] && {
  echo "Run this script as Root!"
  exit
  }

service smbd stop; service nmbd stop

mkdir -p /home/"$USERNAME"/.CONTAINERS/"$NOMESHARE"

mkdir -p /home/"$USERNAME"/.CONTAINERS/"$NOMESHARE"/cache
mkdir -p /home/"$USERNAME"/.CONTAINERS/"$NOMESHARE"/lib
mkdir -p /home/"$USERNAME"/.CONTAINERS/"$NOMESHARE"/log
mkdir -p /home/"$USERNAME"/.CONTAINERS/"$NOMESHARE"/run
mkdir -p /home/"$USERNAME"/.CONTAINERS/"$NOMESHARE"/etc

# Backup Folders:
cp -Rf /var/cache/samba /home/"$USERNAME"/.CONTAINERS/"$NOMESHARE"/cache/
cp -Rf /var/lib/samba /home/"$USERNAME"/.CONTAINERS/"$NOMESHARE"/lib/
cp -Rf /var/log/samba /home/"$USERNAME"/.CONTAINERS/"$NOMESHARE"/log/
cp -Rf /run/samba /home/"$USERNAME"/.CONTAINERS/"$NOMESHARE"/run/
cp -Rf /etc /home/"$USERNAME"/.CONTAINERS/"$NOMESHARE"/
