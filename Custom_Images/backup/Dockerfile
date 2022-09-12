FROM ubuntu:latest

RUN apt update && apt -y install cron rclone nano
RUN apt install --no-install-recommends -y smbclient

RUN touch /var/log/cron.log
CMD cron && tail -f /var/log/cron.log
