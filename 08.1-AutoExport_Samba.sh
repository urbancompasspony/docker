#!/bin/bash

USERNAME="$1"

[ "$EUID" -ne 0 ] && {
  echo "Run this script as Root!"
  exit
  }

service smbd stop; service nmbd stop

mkdir -p /home/"$USERNAME"/.CONTAINERS/"$NOMESHARE"

mkdir -p /home/"$USERNAME"/.CONTAINERS/SAMBA_SHARE/cache
mkdir -p /home/"$USERNAME"/.CONTAINERS/SAMBA_SHARE/lib
mkdir -p /home/"$USERNAME"/.CONTAINERS/SAMBA_SHARE/log
mkdir -p /home/"$USERNAME"/.CONTAINERS/SAMBA_SHARE/run
mkdir -p /home/"$USERNAME"/.CONTAINERS/SAMBA_SHARE/etc

# Backup Folders:
cp -Rf /var/cache/samba /home/"$USERNAME"/.CONTAINERS/SAMBA_SHARE/cache/
cp -Rf /var/lib/samba /home/"$USERNAME"/.CONTAINERS/SAMBA_SHARE/lib/
cp -Rf /var/log/samba /home/"$USERNAME"/.CONTAINERS/SAMBA_SHARE/log/
cp -Rf /run/samba /home/"$USERNAME"/.CONTAINERS/SAMBA_SHARE/run/
cp -Rf /etc /home/"$USERNAME"/.CONTAINERS/SAMBA_SHARE/
