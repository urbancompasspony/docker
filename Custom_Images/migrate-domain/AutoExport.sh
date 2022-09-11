#!/bin/bash

[ "$EUID" -ne 0 ] && {
  echo "Run this script as Root!"
  exit
  }

wd=$(pwd)

service samba-ad-dc stop

mkdir -p "$wd"/ACTIVEDIRECTORY/cache
mkdir -p "$wd"/ACTIVEDIRECTORY/lib
mkdir -p "$wd"/ACTIVEDIRECTORY/log
mkdir -p "$wd"/ACTIVEDIRECTORY/etc
mkdir -p "$wd"/ACTIVEDIRECTORY/run
mkdir -p "$wd"/ACTIVEDIRECTORY/config

# Backup Folders:
cp -Rf /var/cache/samba "$wd"/ACTIVEDIRECTORY/cache/
cp -Rf /var/lib/samba "$wd"/ACTIVEDIRECTORY/lib/
cp -Rf /var/log/samba "$wd"/ACTIVEDIRECTORY/log/
cp -Rf /etc/samba "$wd"/ACTIVEDIRECTORY/etc/
cp -Rf /run/samba "$wd"/ACTIVEDIRECTORY/run/

# Backup Confs:
cp -Rf /etc/hosts "$wd"/ACTIVEDIRECTORY/config/
cp -Rf /etc/krb5.conf "$wd"/ACTIVEDIRECTORY/config/
cp -Rf /etc/resolv.conf "$wd"/ACTIVEDIRECTORY/config/
