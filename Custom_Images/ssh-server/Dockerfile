FROM ubuntu:24.04

EXPOSE 22

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y

RUN apt install -y wget curl openssh-server nano sudo sshfs && \
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /run/sshd

RUN service ssh start

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 ubuntu \
	echo '7ca727e7d44d93429aada44b554977ad:a18528d4d46a7e22b721b326e964b670' | chpasswd

RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

CMD ["/usr/sbin/sshd", "-D"]

ENTRYPOINT ["tail", "-f", "/dev/null"]
