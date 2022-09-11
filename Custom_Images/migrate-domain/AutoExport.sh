#!/bin/bash

[ "$EUID" -ne 0 ] && {
  echo "Run this script as Root!"
  exit
  }

wd=$(pwd)

service samba-ad-dc stop
chmod 777 -R  /var/lib/samba/sysvol/

mkdir -p "$wd"/ACTIVE_DIRECTORY/cache
mkdir -p "$wd"/ACTIVE_DIRECTORY/lib
mkdir -p "$wd"/ACTIVE_DIRECTORY/log
mkdir -p "$wd"/ACTIVE_DIRECTORY/etc
mkdir -p "$wd"/ACTIVE_DIRECTORY/run

# Backup Folders:
cp -Rf /var/cache/samba "$wd"/ACTIVE_DIRECTORY/cache/
cp -Rf /var/lib/samba "$wd"/ACTIVE_DIRECTORY/lib/
cp -Rf /var/log/samba "$wd"/ACTIVE_DIRECTORY/log/
cp -Rf /etc/samba "$wd"/ACTIVE_DIRECTORY/etc/
cp -Rf /run/samba "$wd"/ACTIVE_DIRECTORY/run/
