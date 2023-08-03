# docker

Since it is hard to find compose.yaml base code to use Docker Compose,
everything under this repository is made to be run with bash through .sh scripts.

Maintenance and other configurations need to be made separately.

# F.A.Q. / Cheat Sheet

# Installation

## If running on Ubuntu and you DON'T pretend to use a virtual IP:

First, run these:

$ sudo systemctl stop systemd-resolved

$ sudo systemctl disable systemd-resolved

$ sudo unlink /etc/resolv.conf

Then edit /etc/resolv.conf creating a new file and put this inside:

$ sudo nano /etc/resolv.conf

nameserver IP_OF_YOUR_GATEWAY

search HOSTNAME_OF_GATEWAY_IF_THERES_ANY

Example with pfSense:

nameserver 192.168.0.1

search mypfsense.localdomain

With this, you will not lost ethernet connection on Docker server.

This is not necessary if using macvlan network!

## Installing on Debian-based:

Just install this:

$ sudo apt install docker.io

It's enough to catch stable packages.

## Some options to configure Network:

To change MAC Address, add this line inside script:

--mac-address 02:42:c0:a8:00:02 \

Creating a new network to expose your docker container on LAN through a different IP:

$ sudo docker network create -d macvlan --subnet=192.168.0.0/24 --gateway=192.168.0.1 -o parent=eth0 macvlan

All scripts inside this repository consider macvlan as default network as default. Change if needed.

If you need to create more different subnets through same parent, change .10 to .20 and so on.

Example:

$ sudo docker network create -d macvlan --subnet=192.168.0.0/24 --gateway=192.168.0.1 -o parent=eth0.20 macvlan-custom

Docker will assume that number from . is a sub-parent! But it needs more adjusts, not work out of box.

So for now, run a docker server and it's subs-services on an unique subnet, inside the same DHCP.

Recommended to run every macvlan on it's on network adapter!

## Raspberry Pi

Install this: linux-modules-extra-raspi AND REBOOT!

Or you will get the error "failed to create the macvlan port: operation not supported."

## PiHole on Domain Network

Inside Container:

apt update; apt install nano

nano /etc/pihole/pihole-FTL.conf

Add: RATE_LIMIT=0/0

Restart docker container, not just the pihole-FTL.service.

# Use Cases

## To connect to a container through SSH

$ sudo docker exec -it pihole /bin/bash

# Backup & Restore

## Backup

sudo docker images -> catch the ID!

sudo docker commit -p ID_HERE my-backup # Necessary to stop Container and make an read-only secure version.

sudo docker save -o /path/to/my-backup.tar my-backup

Do not forget about -v (volume) folders and some parameters when running! - And permissions too.

Container backup will store only system configurations, not data files.

## Restore

sudo docker image load -i /path/to/my-backup.tar

Then run with all parameters used before, to keep everything as needed. Example, to restore a backup from file 02-smb-ad-dc:

docker run -t -i -d \
	--network macvlan \
	--ip=THE_SAME_IP_AS_BEFORE \
	-v /SAME/PATH/TO:/var/lib/samba \
	-v /SAME/PATH/TO/ANOTHER:/etc/samba/external \
	--privileged \
  	--restart=unless-stopped \
  	--name samba \
	my-backup

## Backup of Running Image

On the source host:

$ docker export my_container > my_container.tar

Copy the tar archive to the target host using scp:

$ scp my_container.tar user@target_host:~

On the target host:

$ cat my_container.tar | docker import - my_container:latest

Create a new container from the image:

$ docker run -d --name my_new_container my_container:latest

## Samba Domain

Credits:
https://github.com/Fmstrat/samba-domain

Inspired:
https://github.com/crazy-max/docker-samba

Helped by:
https://hub.docker.com/r/instantlinux/samba-dc

Environment variables for quick start

DOMAIN defaults to CORP.EXAMPLE.COM and should be set to your domain
DOMAINPASS should be set to your administrator password, be it existing or new. This can be removed from the environment after the first setup run.
HOSTIP can be set to the IP you want to advertise.
JOIN defaults to false and means the container will provision a new domain. Set this to true to join an existing domain.
JOINSITE is optional and can be set to a site name when joining a domain, otherwise the default site will be used.
DNSFORWARDER is optional and if an IP such as 192.168.0.1 is supplied will forward all DNS requests samba can't resolve to that DNS server
INSECURELDAP defaults to false. When set to true, it removes the secure LDAP requirement. While this is not recommended for production it is required for some LDAP tools. You can remove it later from the smb.conf file stored in the config directory.
MULTISITE defaults to false and tells the container to connect to an OpenVPN site via an ovpn file with no password. For instance, if you have two locations where you run your domain controllers, they need to be able to interact. The VPN allows them to do that.
NOCOMPLEXITY defaults to false. When set to true it removes password complexity requirements including complexity, history-length, min-pwd-age, max-pwd-age

Volumes for quick start
/etc/localtime:/etc/localtime:ro - Sets the timezone to match the host
/data/docker/containers/samba/data/:/var/lib/samba - Stores samba data so the container can be moved to another host if required.
/data/docker/containers/samba/config/samba:/etc/samba/external - Stores the smb.conf so the container can be mored or updates can be easily made.
/data/docker/containers/samba/config/openvpn/docker.ovpn:/docker.ovpn - Optional for connecting to another site via openvpn.
/data/docker/containers/samba/config/openvpn/credentials:/credentials - Optional for connecting to another site via openvpn that requires a username/password. The format for this file should be two lines, with the username on the first, and the password on the second. Also, make sure your ovpn file contains auth-user-pass /credentials

