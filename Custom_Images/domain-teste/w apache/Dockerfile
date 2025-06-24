FROM ubuntu:24.04

ENV TZ="America/Bahia"
ENV CUPSADMIN="admin"
ENV CUPSPASSWORD="p4ssw0rd"
ENV DEBIAN_FRONTEND="noninteractive"

# Ports to Expose
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
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

# DOCKER Config
COPY entrypoint.sh /entrypoint.sh
COPY init.sh /init.sh
COPY cups.sh /
COPY 50-default.conf /etc/rsyslog.d/
COPY rsyslog.conf /etc/

# Final Adjustments
RUN chmod 755 /init.sh
RUN touch /var/log/syslog
RUN chmod +x /cups.sh
RUN chmod +x /init.sh
RUN chmod +x /entrypoint.sh

# Run!
CMD ["/entrypoint.sh"]
