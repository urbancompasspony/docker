FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y

RUN apt install -y pkg-config 

RUN apt install -y attr acl samba smbclient ldap-utils winbind libnss-winbind libpam-winbind krb5-user krb5-kdc supervisor openvpn inetutils-ping nano libpam-krb5 samba-dsdb-modules samba-vfs-modules wget && \
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* &&

COPY init.sh /usr/bin/init.sh
RUN chmod 777 /usr/bin/init.sh

HEALTHCHECK --interval=60s --timeout=15s \
            CMD smbclient -L \\localhost -U % -m SMB3

CMD ["/usr/bin/init.sh"]
