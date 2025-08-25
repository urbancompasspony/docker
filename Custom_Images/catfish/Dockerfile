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
    xvfb \
    openssh-server \
    ssh-askpass \
    xpra
RUN apt-get install -y --no-install-recommends \
    catfish \
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

# Create user space for xpra and fix permissions
RUN mkdir -p /run/xpra/1000 && \
    chown -R ${LOCAL_USER}:${LOCAL_USER} /run/xpra && \
    mkdir -p /run/${LOCAL_USER}/1000 && \
    chown -R ${LOCAL_USER}:${LOCAL_USER} /run/${LOCAL_USER} && \
    mkdir -p /home/${LOCAL_USER}/.xpra && \
    chown -R ${LOCAL_USER}:${LOCAL_USER} /home/${LOCAL_USER} && \
    chmod 755 /home/${LOCAL_USER}

# Create temp directories with proper permissions
RUN mkdir -p /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    mkdir -p /tmp/.ICE-unix && \
    chmod 1777 /tmp/.ICE-unix

USER ${LOCAL_USER}
ENV SHELL=bash
ENV TERM=linux
WORKDIR /home/${LOCAL_USER}
ENV HOSTS="[]"
ENV PORTS="9876"
ENV passw0rd="P4ss0rd"
ENV resolution="800x600"
COPY start.sh /start.sh
CMD ["/usr/sbin/sshd","-D"]
ENTRYPOINT /start.sh
