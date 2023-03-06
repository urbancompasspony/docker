FROM ubuntu:22.04

################################################################################
# ENV BLOCK ####################################################################

# Docker ENV
ENV DEBIAN_FRONTEND noninteractive

################################################################################
# ADD BLOCK ####################################################################

ADD dwagent.sh /dwagent.sh
ADD entrypoint.sh /entrypoint.sh

################################################################################
# RUN BLOCK ####################################################################

RUN apt update && apt upgrade -y

RUN apt install -y wget curl nano openssh-server && \
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd ubuntu && useradd -ms /bin/bash -g ubuntu ubuntu
RUN mkdir -p /home/ubuntu/.ssh
RUN service ssh start &

RUN chmod +x /entrypoint.sh
RUN chmod 755 /entrypoint.sh

################################################################################
# CMD BLOCK ####################################################################

ENTRYPOINT ["/entrypoint.sh"]
