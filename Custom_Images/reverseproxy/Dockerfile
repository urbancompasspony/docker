FROM ubuntu:22.04

# ENV BLOCK ####################################################################

# Docker ENV
ENV DEBIAN_FRONTEND noninteractive

# Apache ENV
ENV APACHE_LOCK_DIR="/var/lock"
ENV APACHE_PID_FILE="/var/run/apache2.pid"
ENV APACHE_RUN_USER="www-data"
ENV APACHE_RUN_GROUP="www-data"
ENV APACHE_LOG_DIR="/var/log/apache2"

################################################################################

# ADD BLOCK ####################################################################

ADD entrypoint.sh /entrypoint.sh
ADD script.sh /script.sh

################################################################################

# RUN BLOCK ####################################################################

RUN apt update && apt upgrade -y

RUN apt install -y wget nano cron apache2 libapache2-mod-proxy-uwsgi libxml2-dev apache2-bin certbot python3-certbot-apache && \
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN touch /var/log/cron.log

RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod proxy_ajp
RUN a2enmod rewrite
RUN a2enmod deflate
RUN a2enmod headers
RUN a2enmod proxy_balancer
RUN a2enmod proxy_connect
RUN a2enmod proxy_html

RUN chmod +x /entrypoint.sh
RUN chmod 755 /entrypoint.sh

RUN chmod +x /script.sh
RUN chmod 755 /script.sh

################################################################################

# CMD BLOCK ####################################################################

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

# End
