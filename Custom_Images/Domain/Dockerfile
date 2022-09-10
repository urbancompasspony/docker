FROM ubuntu:latest
MAINTAINER UrbanCompassPony <urbancompasspony@NOSPAM.NO>

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y

# Install all apps
# The third line is for multi-site config (ping is for testing later)
RUN apt install -y pkg-config
RUN apt install -y attr acl samba smbclient ldap-utils winbind libnss-winbind libpam-winbind krb5-user krb5-kdc supervisor
RUN apt install -y openvpn inetutils-ping nano libpam-krb5 samba-dsdb-modules samba-vfs-modules wget
RUN wget https://raw.githubusercontent.com/urbancompasspony/domain/main/domain -O domain

# Set up script and run
ADD domain /domain
ADD init.sh /init.sh
RUN chmod 755 /init.sh
CMD /init.sh setup
