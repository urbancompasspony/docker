# docker

Since it is hard to find compose.yaml base code to use Docker Compose,
everything under this repository is made to be run with bash through .sh scripts.

Maintenance and other configurations need to be made separately.

# F.A.Q.

## If running on Ubuntu:

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

## Installing on Debian-based:

Just install this:

$ sudo apt install docker.io

It's enough to catch stable packages.

## Some options to configure Network:

$ sudo docker network create -d macvlan --subnet=192.168.0.0/24 --gateway=192.168.0.1 -o parent=eth0.10 macvlan-custom

If you need to create more different subnets through same parent, change .10 to .20 and so on.

Example:

$ sudo docker network create -d macvlan --subnet=192.168.0.0/24 --gateway=192.168.0.1 -o parent=eth0.20 macvlan-custom

Docker will assume that number from . is a sub-parent! But it needs more adjusts, not work out of box.

So for now, run a docker server and it's subs-services on an unique subnet, inside the same DHCP.

Recommended to run every macvlan on it's on network adapter!

## To connect to a container through SSH

$ sudo docker exec -it pihole /bin/bash

## Raspberry Pi

Install this: linux-modules-extra-raspi AND REBOOT!

Or you will get the error "failed to create the macvlan port: operation not supported."

## PiHole

Inside Container:

apt update; apt install nano

nano /etc/pihole/pihole-FTL.conf

Add: RATE_LIMIT=0/0

Restart docker container, not just the pihole-FTL.service.
