FROM ubuntu:24.04

ENV TZ "America/Bahia"
ENV CUPSADMIN admin
ENV CUPSPASSWORD p4ssw0rd

ENV DEBIAN_FRONTEND noninteractive

# Ports to Expose (adicionando portas do Apache)
EXPOSE 42 53 53/udp 80 443 88 88/udp 135 137-138/udp 139 389 389/udp 445 464 464/udp 636 3268-3269 49152-65535 5353/udp

# APT Base
RUN apt update && apt upgrade -y

# System Apps
RUN apt install -y pkg-config

# Common Apps
RUN apt install -y samba smbclient ldap-utils libnss-winbind winbind libpam-winbind krb5-user libpam-krb5 samba-dsdb-modules samba-vfs-modules krb5-kdc \
    apt-utils attr acl curl dialog supervisor openvpn inetutils-ping nano wget less tree iperf

# System Tools
RUN apt install -y rsyslog msitools ldb-tools

# Apache e dependências para CGI
RUN apt install -y apache2 apache2-utils python3 python3-urllib3 sudo

# For Printers
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

# Finish APT
RUN apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# CUPS Config
RUN cp -rp /etc/cups /etc/cups-bak
VOLUME [ "/etc/cups" ]

RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
