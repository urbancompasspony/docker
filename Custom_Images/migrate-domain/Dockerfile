FROM ubuntu:latest
MAINTAINER UrbanCompassPony <urbancompasspony@NOSPAM.NO>

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y

RUN apt install -y pkg-config
RUN apt install -y attr acl samba smbclient ldap-utils winbind libnss-winbind libpam-winbind krb5-user krb5-kdc supervisor openvpn inetutils-ping nano libpam-krb5 samba-dsdb-modules samba-vfs-modules wget

RUN touch /etc/resolv.conf
RUN touch /etc/hosts
RUN touch /etc/krb5.conf
RUN touch /etc/samba/smb.conf

ENTRYPOINT service samba-ad-dc start && /bin/bash
