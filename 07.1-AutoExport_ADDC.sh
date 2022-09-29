#!/bin/bash

[ "$EUID" -ne 0 ] && {
  echo "Run this script as Root!"
  exit
  }

service samba-ad-dc stop

chmod 777 -R  /var/lib/samba/sysvol/

mkdir -p /srv/containers//ACTIVE_DIRECTORY

mkdir -p /srv/containers/ACTIVE_DIRECTORY/cache
mkdir -p /srv/containers/ACTIVE_DIRECTORY/lib
mkdir -p /srv/containers/ACTIVE_DIRECTORY/log
mkdir -p /srv/containers/ACTIVE_DIRECTORY/run
mkdir -p /srv/containers/ACTIVE_DIRECTORY/etc

# Backup Folders:
rsync -vahH /var/cache/samba /srv/containers/ACTIVE_DIRECTORY/cache/
rsync -vahH /var/lib/samba /srv/containers/ACTIVE_DIRECTORY/lib/
rsync -vahH /var/log/samba /srv/containers/ACTIVE_DIRECTORY/log/
rsync -vahH /run/samba /srv/containers/ACTIVE_DIRECTORY/run/
rsync -vahH /etc /srv/containers/ACTIVE_DIRECTORY/
