#!/bin/bash

# Criar usuário/grupo syslog se não existir
if ! getent group syslog >/dev/null; then
    groupadd -r syslog
fi
if ! getent passwd syslog >/dev/null; then
    useradd -r -g syslog -d /var/log -s /usr/sbin/nologin syslog
fi

# Criar diretórios necessários
mkdir -p /var/log /var/run/rsyslog /var/spool/rsyslog
chown syslog:adm /var/log
chown syslog:syslog /var/spool/rsyslog
chmod 755 /var/log /var/run/rsyslog /var/spool/rsyslog

# rsyslog => log
/usr/sbin/rsyslogd &

# ACTIVE DIRECTORY
/init.sh setup &

# CUPS SERVER
/cups.sh &

# APACHE SERVER com Samba CGI
find /var/run/apache2/ -name "cgisock*" -exec unlink {} \; 2>/dev/null || true

service apache2 start &

if [ ! -S /var/run/apache2/cgisock ]; then
  service apache2 restart
  sleep 1
fi

# Block container exit
tail -f /dev/null
