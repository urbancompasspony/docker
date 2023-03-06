FROM ubuntu:22.04

################################################################################
# ENV BLOCK ####################################################################

# Docker ENV
ENV DEBIAN_FRONTEND noninteractive

################################################################################
# ADD BLOCK ####################################################################

ADD dwagent.sh /dwagent.sh
ADD entrypoint.sh /entrypoint.sh
ADD MountModel.sh /MountModel.sh

################################################################################
# RUN BLOCK ####################################################################

RUN apt update && apt upgrade -y

RUN apt install -y wget curl sudo sshfs cifs-utils nano openssh-server && \
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
    
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 ubuntu 
RUN echo 'ubuntu:ubuntu' | chpasswd
RUN mkdir /run/sshd

RUN service ssh start

RUN chmod +x /entrypoint.sh
RUN chmod 755 /entrypoint.sh

EXPOSE 22

################################################################################
# CMD BLOCK ####################################################################

CMD ["/usr/sbin/sshd","-D"]

ENTRYPOINT ["/entrypoint.sh"]
