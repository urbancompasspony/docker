#!/bin/bash

# Script para adaptar smb.conf para a nova estrutura
# Uso: ./adapt_smb_conf.sh [arquivo_origem] [arquivo_destino]

# Definir valores padrão
ORIGEM_CONF="${1:-/etc/samba/smb.conf}"
DESTINO_CONF="${ORIGEM_CONF}.new"

# Verificar se o arquivo de origem existe
if [ ! -f "$ORIGEM_CONF" ]; then
    echo "Erro: Arquivo de origem '$ORIGEM_CONF' não encontrado!"
    exit 1
fi

# Verificar se já existe backup (implica que script já foi executado)
BKP_FILE="${ORIGEM_CONF}.bkp"
if [ -f "$BKP_FILE" ]; then
    echo "Erro: Já existe um backup '$BKP_FILE'!"
    echo "Isso indica que o script já foi executado anteriormente."
    echo "Para executar novamente:"
    echo "1. Remova o backup: rm '$BKP_FILE'"
    echo "2. Ou restaure o original: mv '$BKP_FILE' '$ORIGEM_CONF'"
    exit 1
fi

# Extrair valores do arquivo original
DNS_FORWARDER=$(grep -i "dns forwarder" "$ORIGEM_CONF" | head -1 | cut -d'=' -f2 | xargs)
NETBIOS_NAME=$(grep -i "netbios name" "$ORIGEM_CONF" | head -1 | cut -d'=' -f2 | xargs)
ORIGINAL_REALM=$(grep -i "realm" "$ORIGEM_CONF" | head -1 | cut -d'=' -f2 | xargs)
WORKGROUP=$(grep -i "workgroup" "$ORIGEM_CONF" | head -1 | cut -d'=' -f2 | xargs)

# Extrair a empresa do realm original (ex: de AD.CPD.LOCAL extrai CPD)
EMPRESA=$(echo "$ORIGINAL_REALM" | cut -d'.' -f2 | tr '[:lower:]' '[:upper:]')

# Usar valores padrão se não encontrados
DNS_FORWARDER=${DNS_FORWARDER:-"1.0.0.1"}
NETBIOS_NAME=${NETBIOS_NAME:-"$EMPRESA"}
WORKGROUP=${WORKGROUP:-"AD"}

# Extrair domínio original do netlogon path
DOMINIO_ORIGINAL=$(grep -i "path.*netlogon" "$ORIGEM_CONF" | head -1 | sed 's/.*sysvol\/\([^\/]*\)\/.*/\1/')

# Se não conseguiu extrair do netlogon, tenta extrair do realm
if [ -z "$DOMINIO_ORIGINAL" ]; then
    # Converte AD.CPD.LOCAL para ad.cpd.local
    DOMINIO_ORIGINAL=$(echo "$ORIGINAL_REALM" | tr '[:upper:]' '[:lower:]')
fi

# Se ainda estiver vazio, usa valor baseado na empresa extraída
if [ -z "$DOMINIO_ORIGINAL" ]; then
    DOMINIO_ORIGINAL="ad.${EMPRESA,,}.local"
fi

echo "Adaptando configuração..."
echo "- Empresa extraída: $EMPRESA"
echo "- DNS Forwarder: $DNS_FORWARDER"
echo "- NetBIOS Name: $NETBIOS_NAME"
echo "- Realm original: $ORIGINAL_REALM"
echo "- Workgroup: $WORKGROUP"
echo "- Domínio para netlogon: $DOMINIO_ORIGINAL"

# Criar o novo arquivo smb.conf
cat > "$DESTINO_CONF" << EOF
[global]
  dns forwarder = $DNS_FORWARDER

  netbios name = $NETBIOS_NAME
  realm = $ORIGINAL_REALM
  server role = active directory domain controller
  workgroup = $WORKGROUP
  idmap_ldb:use rfc2307 = yes

  local master = yes
  domain master = yes
  preferred master = yes
  os level = 255

  client min protocol = SMB2
  client max protocol = SMB3

  unix charset = UTF-8
  dos charset = ISO8859-1
  mangled names = no
  read raw = Yes
  write raw = Yes

  vfs objects = recycle, full_audit, dfs_samba4, posixacl, acl_xattr
  audit:failure = none
  full_audit:success = unlinkat renameat
  full_audit:prefix = IP=%I|USER=%u|MACHINE=%m|VOLUME=%S
  log level = 0 vfs:0 rpc_srv:0 rpc_parse:0
  #syslog = 0
  recycle:repository = /mnt/Lixeira/%U
  recycle:excludedir = /mnt/Lixeira,/recycle,/tmp,/temp,/TMP,/TEMP
  recycle:keeptree = yes
  recycle:versions = yes
  recycle:touch = yes
  recycle:touch_mtime = yes
  recycle:noversions = *.tmp,*.temp,*.o,*.obj,*.TMP,*.TEMP
  recycle:exclude = *.tmp,*.temp,*.o,*.obj,*.TMP,*.TEMP

  tls enabled  = yes
  tls keyfile  = tls/key.pem
  tls certfile = tls/cert.pem
  tls cafile   = tls/ca.pem

  ldap server require strong auth = no

  store dos attributes = yes
  map acl inherit = yes
  inherit permissions = yes
  inherit acls = yes
  dos filemode = yes

  hide unreadable = Yes
  hide unwriteable files = yes
  hide dot files = yes

  ad dc functional level = 2016

# Printers
  rpc_server:spoolss = external
  rpc_daemon:spoolssd = fork
  spoolss: architecture = Windows x64
  printing = cups
  printcap name = cups
  load printers = Yes

# Spool
[printers]
  browseable = No
  path = /var/spool/samba
  printable = Yes
  guest ok = No
  read only = Yes
  create mask = 0700

# Drivers
[print$]
  path = /var/lib/samba/printers
  read only = No
  browsable = No
  guest ok = No
  vfs objects = acl_xattr recycle crossrename
  nt acl support = Yes
  inherit acls = Yes
  inherit owner = No
  inherit permissions = Yes
  map acl inherit = Yes
  store dos attributes = Yes
  create mask = 0775
  directory mask = 0775

[sysvol]
  path = /var/lib/samba/sysvol
  read only = No
  browsable = No

[netlogon]
  path = /var/lib/samba/sysvol/$DOMINIO_ORIGINAL/scripts
  read only = No
  browsable = No

# Shared Folders
  include = /etc/samba/external/includes.conf
EOF

echo "Novo arquivo criado: $DESTINO_CONF"
echo ""

echo "Aplicando mudanças automaticamente..."

# Renomear arquivo original para .bkp
mv "$ORIGEM_CONF" "$BKP_FILE"
echo "Arquivo original renomeado para: $BKP_FILE"

# Mover novo arquivo para o local original
mv "$DESTINO_CONF" "$ORIGEM_CONF"
echo "Novo arquivo aplicado: $ORIGEM_CONF"

# Testar configuração
echo ""
echo "Testando nova configuração..."
if command -v testparm >/dev/null 2>&1; then
    if testparm -s "$ORIGEM_CONF" >/dev/null 2>&1; then
        echo "✓ Configuração válida!"
        echo ""
        echo "✓ Script executado com sucesso!"
        echo ""
        echo "Backup mantido em: $BKP_FILE"
    else
        echo "✗ Erro na configuração!"
        echo "Restaurando backup..."
        mv "$ORIGEM_CONF" "${ORIGEM_CONF}.erro"
        mv "$BKP_FILE" "$ORIGEM_CONF"
        echo "Backup restaurado. Arquivo com erro salvo como: ${ORIGEM_CONF}.erro"
        exit 1
    fi
else
    echo "⚠ testparm não encontrado, mas arquivo aplicado."
    echo ""
    echo "Backup mantido em: $BKP_FILE"
fi

echo ""
echo "Exemplos de uso:"
echo "  ./adapt_smb_conf.sh # Usa arquivo padrão"
echo "  ./adapt_smb_conf.sh /srv/containers/container1/config/smb.conf"
echo "  ./adapt_smb_conf.sh /path/to/smb.conf"
