FROM ubuntu:latest

# Install cron
RUN apt update && apt install -y cron && \
    apt autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Add files
ADD script.sh /script.sh
ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /script.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh
