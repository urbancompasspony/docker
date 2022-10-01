#!/bin/bash

[ "$EUID" -ne 0 ] && {
  echo "Run this script as Root!"
  exit
  }

migration_name="dominio"

echo "Seting Migration Name: $migration_name"
datetime=$(date +"%d-%m-%H-%M")
LocalIp=$(hostname -I | awk '{print $1}')
echo "LocalIp detected: $LocalIp"

echo "Creating BKP-Resolv inside /etc"
cp /etc/resolv.conf /etc/resolv-"$datetime"
echo "Stopping SAMBA-AD-DC"
systemctl stop samba-ad-dc
echo "Disabling SAMBA-AD-DC"
systemctl disable samba-ad-dc
echo "Masking SAMBA-AD-DC"
systemctl mask samba-ad-dc
echo "Unmasking SYSTEMD-RESOLVED"
systemctl unmask systemd-resolved
echo "Enabling SYSTEMD-RESOLVED"
systemctl enable systemd-resolved
touch /etc/resolv.conf
echo "nameserver 127.0.0.53" > /etc/resolv.conf
echo "Starting SYSTEMD-RESOLVED"
systemctl start systemd-resolved

echo "Checking if ethernet connection is Ok"
sleep 1
apt update

echo "Creating data, config and log folders inside $migration_name"
mkdir -p /srv/containers/$migration_name/log
mkdir -p /srv/containers/$migration_name/data
mkdir -p /srv/containers/$migration_name/config

echo "Creating syslog and Information files"
touch /srv/containers/$migration_name/log/syslog && chmod 777 /srv/containers/$migration_name/log/syslog
touch /srv/containers/$migration_name/Information

echo "Populating Information file"
echo "CHECK EVERYTHING - REMOVE THIS LINE TO CHECK IF YOU UNDERTOOD!" > /srv/containers/$migration_name/Information
echo "FQDN - ad.example.local" >> /srv/containers/$migration_name/Information
echo "$LocalIp" >> /srv/containers/$migration_name/Information
echo "Admin Password" >> /srv/containers/$migration_name/Information
echo "LAN DNS - 192.168.0.11" >> /srv/containers/$migration_name/Information
echo "$HOSTNAME" >> /srv/containers/$migration_name/Information
echo "macvlan" >> /srv/containers/$migration_name/Information

# Backup Folders:

echo "BackingUp samba folder and smb.conf & krb5.conf files"
rsync -vaAxhHt /var/lib/samba/ /srv/containers/$migration_name/data/
rsync -vaAxhHt /etc/samba/smb.conf /srv/containers/$migration_name/config/
rsync -vaAxhHt /etc/krb5.conf /srv/containers/$migration_name/data/private/

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
read

exit 0
