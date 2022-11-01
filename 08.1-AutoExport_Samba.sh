#!/bin/bash

[ "$EUID" -ne 0 ] && {
  echo "Run this script as Root!"
  exit
  }

migration_name="SAMBA_SHARE"

echo "Seting Migration Name: $migration_name"
datetime=$(date +"%d-%m-%H-%M")
LocalIp=$(hostname -I | awk '{print $1}')
echo "LocalIp detected: $LocalIp"

echo "Stopping SAMBA"
systemctl stop smbd; systemctl stop nmbd
echo "Disabling SAMBA"
systemctl disable smbd; systemctl disable nmbd
echo "Masking SAMBA"
systemctl mask smbd; systemctl mask nmbd

echo "Checking if ethernet connection is Ok"
sleep 1
apt update

mkdir -p /srv/containers/$migration_name

mkdir -p /srv/containers/$migration_name/cache
mkdir -p /srv/containers/$migration_name/lib
mkdir -p /srv/containers/$migration_name/log
mkdir -p /srv/containers/$migration_name/run
mkdir -p /srv/containers/$migration_name/etc

echo "Creating syslog and Information files"
touch /srv/containers/$migration_name/log/syslog && chmod 777 /srv/containers/$migration_name/log/syslog
touch /srv/containers/$migration_name/Information

echo "Populating Information file"
echo "CHECK EVERYTHING - REMOVE THIS LINE TO CHECK IF YOU UNDERTOOD!" > /srv/containers/$migration_name/Information
echo "$LocalIp" >> /srv/containers/$migration_name/Information
echo "$migration_name" >> /srv/containers/$migration_name/Information
echo "/mnt" >> /srv/containers/$migration_name/Information

# Backup Folders:

echo "BackingUp samba folder and smb.conf & krb5.conf files"
rsync -vaAxhHt /var/cache/samba /srv/containers/$migration_name/cache/
rsync -vaAxhHt /var/lib/samba /srv/containers/$migration_name/lib/
rsync -vaAxhHt /var/log/samba /srv/containers/$migration_name/log/
rsync -vaAxhHt /run/samba /srv/containers/$migration_name/run/
rsync -vaAxhHt /etc /srv/containers/$migration_name/

echo "TARing $migration_name.tar inside /srv/containers"
tar -cvf /srv/containers/$migration_name.tar -C /srv/containers/$migration_name .

echo "Simple backup for new config for new container"
rsync -va /srv/containers/$migration_name /srv/containers/BKP-$migration_name

nano /srv/containers/$migration_name/Information

echo "#################################"
echo "# SYSTEM MIGRATED SUCCESSFULLY! ######################################################"
echo "# SHUTDOWN and change IP LAN $LocalIp of this system to not conflict with container! #"
echo "######################################################################################"
echo " "
echo "Press Enter to Exit."

exit 1
