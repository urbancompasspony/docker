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

RUN curl -fsSL https://raw.githubusercontent.com/coder/wush/main/install.sh | bash

RUN cp /usr/local/bin/wush /usr/bin/
RUN chmod +x /usr/bin/wush

COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT /start.sh

#CMD ["/usr/sbin/sshd","-D"]
