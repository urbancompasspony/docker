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
    less \
    gpgv \
    libfuse2 \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    lsb-release \
    mesa-utils \
    openssh-server \
    ssh-askpass
    
RUN apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

ARG LOCAL_USER=user

ARG PRIV_CMDS='/bin/ch*,/bin/cat,/bin/gunzip,/bin/tar,/bin/mkdir,/bin/ps,/bin/mv,/bin/cp,/usr/bin/apt*,/usr/bin/pip*,/bin/yum,/bin/snap,/bin/curl,/bin/tee'

RUN adduser --disabled-password --gecos "ubuntu" --uid 1000 ${LOCAL_USER}  && \
    usermod -aG sudo ${LOCAL_USER} && \
    echo "$LOCAL_USER ALL=NOPASSWD: $PRIV_CMDS" >> /etc/sudoers

USER ${LOCAL_USER}

ENV SHELL=bash
ENV TERM=linux

WORKDIR /home/${LOCAL_USER}

RUN curl -fsSL https://raw.githubusercontent.com/coder/wush/main/install.sh | bash

COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT /start.sh
#CMD ["/usr/sbin/sshd","-D"]
