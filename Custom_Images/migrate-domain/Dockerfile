FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y

RUN apt install -y pkg-config
RUN apt install -y rsyslog attr acl samba smbclient ldap-utils winbind libnss-winbind libpam-winbind krb5-user krb5-kdc supervisor openvpn inetutils-ping nano libpam-krb5 samba-dsdb-modules samba-vfs-modules wget && \
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

ADD 50-default.conf /etc/rsyslog.d/
ADD rsyslog.conf /etc/

RUN touch /etc/resolv.conf
RUN touch /etc/hosts
RUN touch /etc/krb5.conf
RUN touch /etc/samba/smb.conf

ENTRYPOINT /usr/sbin/rsyslogd && service samba-ad-dc start && /bin/bash
