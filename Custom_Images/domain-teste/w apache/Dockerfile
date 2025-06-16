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
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

# Apache Configuration para Samba CGI
RUN a2enmod cgi headers rewrite

# Criar estrutura para aplicação web Samba
RUN mkdir -p /var/www/samba-admin/cgi-bin \
    && mkdir -p /var/log/samba-cgi \
    && chown -R www-data:www-data /var/www/samba-admin \
    && chmod 755 /var/www/samba-admin/cgi-bin \
    && touch /var/log/samba-cgi/actions.log \
    && chown www-data:www-data /var/log/samba-cgi/actions.log

# Configurar sudoers para permitir www-data executar samba-tool
RUN echo "www-data ALL=(root) NOPASSWD: /usr/bin/samba-tool" > /etc/sudoers.d/samba-cgi \
    && chmod 440 /etc/sudoers.d/samba-cgi

# Configuração Apache para Samba Admin
RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/samba-admin.conf && \
    echo '    ServerName localhost' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '    DocumentRoot /var/www/samba-admin' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '    ScriptAlias /cgi-bin/ "/var/www/samba-admin/cgi-bin/"' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '    <Directory "/var/www/samba-admin/cgi-bin/">' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '        AddHandler cgi-script .cgi .sh' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '        AllowOverride None' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '    <Directory "/var/www/samba-admin">' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '        Options -Indexes +FollowSymLinks' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '        AllowOverride None' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '    ErrorLog ${APACHE_LOG_DIR}/samba-admin_error.log' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '    CustomLog ${APACHE_LOG_DIR}/samba-admin_access.log combined' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '    Header always set X-Content-Type-Options nosniff' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '    Header always set X-Frame-Options DENY' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '    Header always set X-XSS-Protection "1; mode=block"' >> /etc/apache2/sites-available/samba-admin.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-available/samba-admin.conf

# Habilitar o site Samba Admin
RUN a2ensite samba-admin.conf

# DOCKER Config (mantendo arquivos originais)
COPY entrypoint.sh /entrypoint.sh
COPY init.sh /init.sh
COPY cups.sh /
COPY 50-default.conf /etc/rsyslog.d/
COPY rsyslog.conf /etc/

# Novos arquivos para integração Apache + Samba CGI
COPY samba-admin.cgi /var/www/samba-admin/cgi-bin/
COPY index.html /var/www/samba-admin/
COPY apache-start.sh /

# Final Adjustments (mantendo originais + novos)
RUN chmod 755 /init.sh
RUN touch /var/log/syslog
RUN chmod +x /cups.sh
RUN chmod +x /init.sh
RUN chmod +x /entrypoint.sh
RUN chmod +x /apache-start.sh
RUN chmod 755 /var/www/samba-admin/cgi-bin/samba-admin.cgi

# Run! (modificado para incluir Apache)
CMD /entrypoint.sh
