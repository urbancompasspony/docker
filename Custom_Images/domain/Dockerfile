FROM ubuntu:latest
MAINTAINER UrbanCompassPony <urbancompasspony@NOSPAM.NO>

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y

RUN apt install -y pkg-config
RUN apt install -y attr acl samba smbclient ldap-utils winbind libnss-winbind libpam-winbind krb5-user krb5-kdc supervisor openvpn inetutils-ping nano libpam-krb5 samba-dsdb-modules samba-vfs-modules wget

HEALTHCHECK --interval=60s --timeout=15s \
            CMD smbclient -L \\localhost -U % -m SMB3

# Set up script and run
ADD init.sh /init.sh
RUN chmod 755 /init.sh
CMD /init.sh setup
