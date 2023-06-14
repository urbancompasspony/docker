FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y

RUN apt install -y pkg-config

RUN apt install -y inetutils-ping nano curl wget rbenv git ruby rubygems ruby-pg postgresql-common libpq-dev libpcap0.8 bundler ruby-pcaprub libpc>
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/rapid7/metasploit-framework

RUN rbenv rehash
RUN gem install bundler

COPY metasploit-framework /metasploit-framework

RUN cd metasploit-framework; bundle install

RUN ln -s /metasploit-framework/msf* /usr/local/bin

# TO RUN
# docker run --rm -it urbancompasspony/metasploit-arm msfconsole
