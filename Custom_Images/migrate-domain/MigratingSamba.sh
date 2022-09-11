#!/bin/bash

# Change here to the SAME configurations of Domain to be migrated!
HOSTNAME="atomic-pi"
NAME="dominio"
NETWORKLAN="host"

docker run -t -i \
-h $HOSTNAME \
--name $NAME \
--privileged \
--restart=unless-stopped \
-v /etc/localtime:/etc/localtime:ro \
--network $NETWORKLAN \
-v /var/cache/samba:/var/cache/samba \
-v /var/lib/samba:/var/lib/samba \
-v /var/log/samba:/var/log/samba \
-v /etc/samba:/etc/samba \
-v /run/samba:/run/samba \
-v /etc/hosts:/etc/hosts \
-v /etc/krb5.conf:/etc/krb5.conf \
-v /etc/resolv.conf:/etc/resolv.conf \
urbancompasspony/migrate-domain:latest

#-v /mnt:/mnt \
#-v $(pwd)/FOLDER:/mnt \
