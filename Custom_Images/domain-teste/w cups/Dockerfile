FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

ENV TZ "America/Bahia"
ENV CUPSADMIN admin
ENV CUPSPASSWORD p4ssw0rd

EXPOSE 631
EXPOSE 5353/udp

RUN apt update && apt upgrade -y

RUN apt install -y pkg-config
RUN apt install -y apt-utils attr acl curl dialog samba smbclient ldap-utils winbind libnss-winbind libpam-winbind krb5-user krb5-kdc supervisor openvpn inetutils-ping nano libpam-krb5 samba-dsdb-modules samba-vfs-modules wget

RUN apt install -y rsyslog less

RUN apt install -qqy \
    usbutils \
    cups \
    cups-filters \
    printer-driver-all \
    printer-driver-cups-pdf \
    printer-driver-foo2zjs \
    foomatic-db-compressed-ppds \
    openprinting-ppds \
    hpijs-ppds \
    hp-ppd \
    hplip \
    avahi-daemon

RUN apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

ADD init.sh /init.sh
ADD 50-default.conf /etc/rsyslog.d/
ADD rsyslog.conf /etc/

RUN chmod 755 /init.sh
RUN touch /var/log/syslog

RUN cp -rp /etc/cups /etc/cups-bak
VOLUME [ "/etc/cups" ]

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh
CMD /usr/sbin/rsyslogd && /init.sh setup
