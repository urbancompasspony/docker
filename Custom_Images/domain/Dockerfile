FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y

RUN apt install -y pkg-config
RUN apt install -y attr acl curl dialog rsyslog samba smbclient ldap-utils winbind libnss-winbind libpam-winbind krb5-user krb5-kdc supervisor openvpn inetutils-ping nano libpam-krb5 samba-dsdb-modules samba-vfs-modules wget && \
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

ADD init.sh /init.sh
RUN chmod 755 /init.sh

ADD 50-default.conf /etc/rsyslog.d/
ADD rsyslog.conf /etc/
RUN touch /var/log/syslog

CMD /usr/sbin/rsyslogd && /init.sh setup
