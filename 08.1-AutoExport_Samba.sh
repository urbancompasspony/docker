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
rsync -vaAxhHt /var/cache/samba /srv/containers/SAMBA_SHARE/cache/
rsync -vaAxhHt /var/lib/samba /srv/containers/SAMBA_SHARE/lib/
rsync -vaAxhHt /var/log/samba /srv/containers/SAMBA_SHARE/log/
rsync -vaAxhHt /run/samba /srv/containers/SAMBA_SHARE/run/
rsync -vaAxhHt /etc /srv/containers/SAMBA_SHARE/
