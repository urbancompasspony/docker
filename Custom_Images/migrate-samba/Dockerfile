FROM ubuntu:latest
MAINTAINER UrbanCompassPony <urbancompasspony@NOSPAM.NO>

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y

RUN apt install -y pkg-config
RUN apt install -y attr acl samba smbclient winbind supervisor inetutils-ping nano wget

RUN touch /etc/resolv.conf
RUN touch /etc/hosts
RUN touch /etc/krb5.conf
RUN touch /etc/samba/smb.conf

HEALTHCHECK --interval=60s --timeout=15s \
            CMD smbclient -L \\localhost -U % -m SMB3

ENTRYPOINT service smbd start && service nmbd start && systemctl winbind start && /bin/bash
