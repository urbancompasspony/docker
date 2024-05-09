FROM ubuntu:24.04

EXPOSE 22

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y

RUN apt install -y wget curl sshpass openssh-server nano sudo sshfs && \
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

RUN chmod 755 /entrypoint.sh

RUN mkdir /run/sshd

# Start Users
RUN useradd -rm -d /home/userwetty -s /bin/bash -g root -G sudo -u 1001 userwetty
RUN echo 'userwetty:a18528d4d46a7e22b721b326e964b670' | chpasswd

RUN useradd -rm -d /home/admin -s /bin/bash -g root -G sudo -u 1002 admin
RUN echo 'admin:aezakmi' | chpasswd
# End Users - Remember to change on RUN file when adding or excluding someone from here.

RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
	sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config && \
	sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \
	sed -i 's/#AddressFamily any/AddressFamily any/' /etc/ssh/sshd_config && \
	echo "export VISIBLE=now" >> /etc/profile

ENTRYPOINT ["/entrypoint.sh"]
