#!/bin/bash
echo "Iniciando Oracle com dados existentes..."
    
# Definir variáveis de ambiente necessárias
umask 022
export ORACLE_SID=XE
export ORAENV_ASK=NO
export ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
export PATH=$PATH:$ORACLE_HOME/bin

chown -R oracle:oinstall /opt/oracle/admin
chown -R oracle:oinstall /opt/oracle/product/21c/dbhomeXE/rdbms/audit
chmod -R 755 /opt/oracle/admin
chmod -R 755 /opt/oracle/product/21c/dbhomeXE/rdbms/audit

# Função para verificar se existem dados Oracle
check_oracle_data() {
    if [ -f "/opt/oracle/oradata/XE/system01.dbf" ]; then
        return 0  # Dados existem
    else
        return 1  # Dados não existem
    fi
}

# Garantir que o Oracle está registrado no sistema
if ! grep -q "XE:" /etc/oratab 2>/dev/null; then
  echo "XE:$ORACLE_HOME:N" > /etc/oratab
fi

# Se existem dados, apenas iniciar. Se não, configurar.
if check_oracle_data; then
    echo "Dados Oracle detectados - iniciando Oracle XE..."
    
    # Tentar iniciar e verificar diretamente se falhou
    if ! /etc/init.d/oracle-xe-21c start && [ -n "$ORACLE_PWD" ]; then
        echo "Service falhou, tentando startup manual..."
        
        # Criar diretórios necessários primeiro
        mkdir -p /opt/oracle/admin/XE/adump
        chown -R oracle:oinstall /opt/oracle/admin
        
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
    
else
    echo "Configurando Oracle XE pela primeira vez..."
    if [ -n "$ORACLE_PWD" ]; then
        (echo "$ORACLE_PWD"; echo "$ORACLE_PWD") | /etc/init.d/oracle-xe-21c configure
    else
        /etc/init.d/oracle-xe-21c configure
    fi
fi

# Loop para manter rodando
while true; do
    if ! pgrep -f "pmon_XE" > /dev/null; then
        echo "$(date) - Oracle não está rodando, tentando iniciar..."
        
        # Tentar iniciar e verificar diretamente se falhou
        if ! /etc/init.d/oracle-xe-21c start && check_oracle_data; then
            echo "$(date) - Service falhou no loop, tentando startup manual..."
            su - oracle -c "
export ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
export ORACLE_SID=XE
export PATH=\$ORACLE_HOME/bin:\$PATH
sqlplus / as sysdba @/tmp/startup.sql
" 2>/dev/null
        fi
    fi
    
    if ! pgrep tnslsnr > /dev/null; then
        echo "$(date) - Listener não está rodando, iniciando..."
        export ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
        export PATH=$ORACLE_HOME/bin:$PATH
        lsnrctl start
    fi
    
    sleep 1m
done
