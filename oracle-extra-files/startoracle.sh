#!/bin/bash

 if ! grep -q "XE:" /etc/oratab 2>/dev/null; then
    echo "XE:/opt/oracle/product/21c/dbhomeXE:N" >> /etc/oratab
  fi

  chown -R oracle:oinstall /opt/oracle/admin

  cat > /tmp/startup.sql << 'EOF'
STARTUP;
ALTER PLUGGABLE DATABASE ALL OPEN;
EXIT;
EOF

  su - oracle -c "
export ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
export ORACLE_SID=XE
export PATH=/opt/oracle/product/21c/dbhomeXE/bin:\$PATH
sqlplus / as sysdba @/tmp/startup.sql
"

while true; do
    pmon=`ps -ef | grep pmon_$ORACLE_SID | grep -v grep`

    if [ "$pmon" == "" ]
    then
        date
        /etc/init.d/oracle-xe-21c start
    fi
    sleep 1m
done;
