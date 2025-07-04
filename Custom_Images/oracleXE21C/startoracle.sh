#!/bin/bash

start_existing_oracle() {
    echo "Iniciando Oracle com dados existentes..."
    
    # Definir variáveis de ambiente necessárias
    umask 022
    ORACLE_SID=XE
    ORAENV_ASK=NO
    ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
    PATH=$PATH:$ORACLE_HOME/bin
    
    # Tentar iniciar via service primeiro
    echo "Tentando iniciar via service..."
    /etc/init.d/oracle-xe-21c start
    
    # Se falhar, tentar com sqlplus usando a senha
    echo "XE:$ORACLE_HOME:N" > /etc/oratab
    
    chown -R oracle:oinstall /opt/oracle/admin
    chown -R oracle:oinstall /opt/oracle/product/21c/dbhomeXE/rdbms/audit
    chmod -R 755 /opt/oracle/admin
    chmod -R 755 /opt/oracle/product/21c/dbhomeXE/rdbms/audit
    
    if [ $? -ne 0 ] && [ ! -z "$ORACLE_PWD" ]; then
      cat > /tmp/startup.sql << 'EOF'
STARTUP;
ALTER PLUGGABLE DATABASE ALL OPEN;
EXIT;
EOF

# Tentar executar como oracle
      su - oracle -c "
export ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
export ORACLE_SID=XE
export PATH=\$ORACLE_HOME/bin:\$PATH
sqlplus / as sysdba @/tmp/startup.sql
"
    fi
}

while true; do
    pmon=`ps -ef | grep pmon_$ORACLE_SID | grep -v grep`

    if [ "$pmon" == "" ]
    then
        date
        /etc/init.d/oracle-xe-21c start
    fi
    sleep 1m
done;
