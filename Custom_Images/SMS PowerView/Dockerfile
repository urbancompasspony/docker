FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y

RUN apt install -y pkg-config
RUN apt install -y wget curl nano xvfb
RUN apt install -y openjdk-17-jre && \
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

ADD SMS /SMS
ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
