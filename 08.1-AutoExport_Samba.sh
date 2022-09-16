#!/bin/bash

USERNAME="$1"

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
cp -Rf /var/cache/samba /srv/containers/SAMBA_SHARE/cache/
cp -Rf /var/lib/samba /srv/containers/SAMBA_SHARE/lib/
cp -Rf /var/log/samba /srv/containers/SAMBA_SHARE/log/
cp -Rf /run/samba /srv/containers/SAMBA_SHARE/run/
cp -Rf /etc /srv/containers/SAMBA_SHARE/
