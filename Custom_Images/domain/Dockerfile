FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y

RUN apt install -y pkg-config
RUN apt install -y attr acl rsyslog samba smbclient ldap-utils winbind libnss-winbind libpam-winbind krb5-user krb5-kdc supervisor openvpn inetutils-ping nano libpam-krb5 samba-dsdb-modules samba-vfs-modules wget && \
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# too many logs ;/
#HEALTHCHECK --interval=60s --timeout=15s \
#            CMD smbclient -L \\localhost -U % -m SMB3

ADD ./logentries.conf /etc/rsyslog.d/logentries.conf

ADD init.sh /init.sh
RUN chmod 755 /init.sh
CMD /init.sh setup
