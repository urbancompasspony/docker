FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

ADD entrypoint.sh /entrypoint.sh

RUN apt update && apt upgrade -y

RUN apt install -y nano cron apache2 libapache2-mod-proxy-uwsgi libxml2-dev apache2-bin certbot python3-certbot-apache && \
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

ENTRYPOINT /entrypoint.sh
