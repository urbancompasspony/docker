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

RUN useradd -rm -d /home/userweb -s /bin/bash -g root -G sudo -u 1001 userweb

RUN echo 'userweb:a18528d4d46a7e22b721b326e964b670' | chpasswd

RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

RUN service ssh start

CMD ["/usr/sbin/sshd", "-D"]

ENTRYPOINT ["/entrypoint.sh"]
