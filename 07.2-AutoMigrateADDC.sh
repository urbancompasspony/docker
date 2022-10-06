#!/bin/bash

[ "$EUID" -ne 0 ] && {
  echo "Run this script as Root!"
  exit
  }

migration_name="dominio"

echo "Setting Migration Name: $migration_name"
datetime=$(date +"%d-%m-%H-%M")
LocalIp=$(hostname -I | awk '{print $1}')
echo "LocalIp detected: $LocalIp"

echo "Stopping SAMBA-AD-DC"
systemctl stop samba-ad-dc

echo "Creating data, config and log folders inside $migration_name"
mkdir -p /srv/exported/$migration_name/log
mkdir -p /srv/exported/$migration_name/data
mkdir -p /srv/exported/$migration_name/config

echo "Creating syslog and Information files"
touch /srv/exported/$migration_name/log/syslog && chmod 777 /srv/exported/$migration_name/log/syslog
touch /srv/exported/$migration_name/Information

echo "Populating Information file"
echo "CHECK EVERYTHING - REMOVE THIS LINE TO CHECK IF YOU UNDERTOOD!" > /srv/exported/$migration_name/Information
echo "FQDN - ad.example.local" >> /srv/exported/$migration_name/Information
echo "$LocalIp" >> /srv/exported/$migration_name/Information
echo "Admin Password" >> /srv/exported/$migration_name/Information
echo "LAN DNS - 192.168.0.11" >> /srv/exported/$migration_name/Information
echo "$HOSTNAME" >> /srv/exported/$migration_name/Information
echo "macvlan" >> /srv/exported/$migration_name/Information

# Backup Folders:

echo "BackingUp samba folder and smb.conf & krb5.conf files"
rsync -vaAxhHt /var/lib/samba/ /srv/exported/$migration_name/data/
rsync -vaAxhHt /etc/samba/smb.conf /srv/exported/$migration_name/config/
rsync -vaAxhHt /etc/krb5.conf /srv/exported/$migration_name/data/private/

echo "Stopping SAMBA-AD-DC"
systemctl start samba-ad-dc

nano /srv/exported/$migration_name/Information

echo "TARing $migration_name.tar inside /srv/containers"
tar -cvf /srv/exported/$migration_name.tar -C /srv/exported/$migration_name .

echo "Remove temp dir"
#rm -R /srv/exported/$migration_name

echo "#################################"
echo "# SYSTEM MIGRATED SUCCESSFULLY! #"
echo "#################################"
echo " "
echo "Press Enter to Exit."

read
sleep 1

exit 0
