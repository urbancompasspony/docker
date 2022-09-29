#!/bin/bash

[ "$EUID" -ne 0 ] && {
  echo "Run this script as Root!"
  exit
  }

service smbd stop; service nmbd stop

mkdir -p /srv/containers/SAMBA_SHARE

mkdir -p /srv/containers/SAMBA_SHARE/cache
mkdir -p /srv/containers/SAMBA_SHARE/lib
mkdir -p /srv/containers/SAMBA_SHARE/log
mkdir -p /srv/containers/SAMBA_SHARE/run
mkdir -p /srv/containers/SAMBA_SHARE/etc

# Backup Folders:
rsync -vahH /var/cache/samba /srv/containers/SAMBA_SHARE/cache/
rsync -vahH /var/lib/samba /srv/containers/SAMBA_SHARE/lib/
rsync -vahH /var/log/samba /srv/containers/SAMBA_SHARE/log/
rsync -vahH /run/samba /srv/containers/SAMBA_SHARE/run/
rsync -vahH /etc /srv/containers/SAMBA_SHARE/
