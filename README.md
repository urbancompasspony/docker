# docker

Since is hard to find compose.yaml base code to use Docker Compose,
everything under this repository is made to be run with bash through .sh scripts.

Maintenance and other configurations need to be made separately.

## Configuring Network:
sudo docker network create -d macvlan --subnet=192.168.0.0/24 --gateway=192.168.0.1 -o parent=eth0 macvlan-custom

## To connect to an container that is running:
sudo docker exec -it pihole /bin/bash
