FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install locales -y && \
    locale-gen pt_BR.UTF-8

RUN apt-get install -y \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    dpkg \
    gcc \
    sed \
    sudo \
    grep \
    wget \
    xterm \
    less \
    gpgv \
    libfuse2 \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    lsb-release \
    mesa-utils \
    xvfb

RUN apt-get install -y wget && \
    wget -q https://xpra.org/gpg.asc -O- | apt-key add - &&  \
    echo "deb https://xpra.org/ jammy main" >> /etc/apt/sources.list.d/xpra.list && \
    apt-get update && \
    apt-get install -y xpra

RUN apt-get install -y --no-install-recommends \
    virt-manager \
    dbus-x11 \
    libglib2.0-bin \
    gir1.2-spiceclientgtk-3.0

RUN apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

ARG LOCAL_USER=user

ARG PRIV_CMDS='/bin/ch*,/bin/cat,/bin/gunzip,/bin/tar,/bin/mkdir,/bin/ps,/bin/mv,/bin/cp,/usr/bin/apt*,/usr/bin/pip*,/bin/yum,/bin/snap,/bin/curl,/bin/tee'

RUN adduser --disabled-password --gecos "ubuntu" --uid 1000 ${LOCAL_USER}  && \
    usermod -aG sudo ${LOCAL_USER} && \
    echo "$LOCAL_USER ALL=NOPASSWD: $PRIV_CMDS" >> /etc/sudoers

# Create user space for xpra
RUN mkdir -p /run/xpra/1000 && \
    chown -R ${LOCAL_USER}:${LOCAL_USER} /run/xpra && \
    mkdir -p /run/${LOCAL_USER}/1000 && \
    chown -R ${LOCAL_USER}:${LOCAL_USER} /run/${LOCAL_USER}

USER ${LOCAL_USER}

ENV SHELL=bash
ENV TERM=linux

WORKDIR /home/${LOCAL_USER}

ENV PORTS="9876"
ENV passw0rd="P4ss0rd"
ENV HOSTS="[]"
ENV resolution="800x600"

COPY startapp.sh /startapp.sh

CMD /startapp.sh
