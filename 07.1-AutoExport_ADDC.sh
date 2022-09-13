#!/bin/bash

USERNAME="$1"

[ "$EUID" -ne 0 ] && {
  echo "Run this script as Root!"
  exit
  }

service samba-ad-dc stop

chmod 777 -R  /var/lib/samba/sysvol/

mkdir -p /home/"$USERNAME"/.CONTAINERS/ACTIVE_DIRECTORY

mkdir -p /home/"$USERNAME"/.CONTAINERS/ACTIVE_DIRECTORY/cache
mkdir -p /home/"$USERNAME"/.CONTAINERS/ACTIVE_DIRECTORY/lib
mkdir -p /home/"$USERNAME"/.CONTAINERS/ACTIVE_DIRECTORY/log
mkdir -p /home/"$USERNAME"/.CONTAINERS/ACTIVE_DIRECTORY/run
mkdir -p /home/"$USERNAME"/.CONTAINERS/ACTIVE_DIRECTORY/etc

# Backup Folders:
cp -Rf /var/cache/samba /home/"$USERNAME"/.CONTAINERS/ACTIVE_DIRECTORY/cache/
cp -Rf /var/lib/samba /home/"$USERNAME"/.CONTAINERS/ACTIVE_DIRECTORY/lib/
cp -Rf /var/log/samba /home/"$USERNAME"/.CONTAINERS/ACTIVE_DIRECTORY/log/
cp -Rf /run/samba /home/"$USERNAME"/.CONTAINERS/ACTIVE_DIRECTORY/run/
cp -Rf /etc /home/"$USERNAME"/.CONTAINERS/ACTIVE_DIRECTORY/
