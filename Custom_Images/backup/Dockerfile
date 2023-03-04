FROM ubuntu:22.04

RUN apt update && apt -y install cron rclone nano
RUN apt install --no-install-recommends -y smbclient && \
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN touch /var/log/cron.log
CMD cron &
CMD tail -f /var/log/cron.log
