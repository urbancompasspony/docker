#!/bin/bash

echo "Iniciando adaptação automática do arquivo: $ORIGEM_CONF"
echo "Extraindo configurações do arquivo original..."

# Definir valores padrão
ORIGEM_CONF="${1:-/etc/samba/smb.conf}"
DESTINO_CONF="${ORIGEM_CONF}.new"
BKP_FILE="${ORIGEM_CONF}.bkp"

DNS_FORWARDER=$(grep -i "dns forwarder" "$ORIGEM_CONF" | head -1 | cut -d'=' -f2 | xargs)
NETBIOS_NAME=$(grep -i "netbios name" "$ORIGEM_CONF" | head -1 | cut -d'=' -f2 | xargs)
ORIGINAL_REALM=$(grep -i "realm" "$ORIGEM_CONF" | head -1 | cut -d'=' -f2 | xargs)
WORKGROUP=$(grep -i "workgroup" "$ORIGEM_CONF" | head -1 | cut -d'=' -f2 | xargs)

# Extrair caminhos da lixeira
RECYCLE_REPOSITORY=$(grep -i "recycle:repository" "$ORIGEM_CONF" | head -1 | cut -d'=' -f2 | xargs | sed 's|/%U$||')
RECYCLE_EXCLUDEDIR=$(grep -i "recycle:excludedir" "$ORIGEM_CONF" | head -1 | cut -d'=' -f2 | xargs)

# Extrair a empresa do realm original (ex: de AD.CPD.LOCAL extrai CPD)
EMPRESA=$(echo "$ORIGINAL_REALM" | cut -d'.' -f2 | tr '[:lower:]' '[:upper:]')

# Usar valores padrão se não encontrados
DNS_FORWARDER=${DNS_FORWARDER:-"1.0.0.1"}
NETBIOS_NAME=${NETBIOS_NAME:-"$EMPRESA"}
WORKGROUP=${WORKGROUP:-"AD"}

# Se não encontrou configuração da lixeira, usar valores padrão
if [ -z "$RECYCLE_REPOSITORY" ]; then
    RECYCLE_REPOSITORY="/mnt/Lixeira"
fi

if [ -z "$RECYCLE_EXCLUDEDIR" ]; then
    RECYCLE_EXCLUDEDIR="$RECYCLE_REPOSITORY,/recycle,/tmp,/temp,/TMP,/TEMP"
else
    # Verificar se o caminho da lixeira está no excludedir
    FIRST_EXCLUDE_PATH=$(echo "$RECYCLE_EXCLUDEDIR" | cut -d',' -f1 | xargs)
    
    # Se o primeiro caminho não for igual ao repository, atualizar
    if [ "$FIRST_EXCLUDE_PATH" != "$RECYCLE_REPOSITORY" ]; then
        # Substituir o primeiro caminho pelo repository, mantendo o resto
        REST_EXCLUDES=$(echo "$RECYCLE_EXCLUDEDIR" | cut -d',' -f2- | sed 's/^[[:space:]]*//')
        RECYCLE_EXCLUDEDIR="$RECYCLE_REPOSITORY,$REST_EXCLUDES"
    fi
fi

# Extrair domínio original do netlogon path
DOMINIO_ORIGINAL=$(grep -i "path.*netlogon" "$ORIGEM_CONF" | head -1 | sed 's/.*sysvol\/\([^\/]*\)\/.*/\1/')

# Se não conseguiu extrair do netlogon, tenta extrair do realm
if [ -z "$DOMINIO_ORIGINAL" ]; then
    # Converte por exemplo AD.CPD.LOCAL para ad.cpd.local
    DOMINIO_ORIGINAL=$(echo "$ORIGINAL_REALM" | tr '[:upper:]' '[:lower:]')
fi

# Se ainda estiver vazio, usa valor baseado na empresa extraída
if [ -z "$DOMINIO_ORIGINAL" ]; then
    DOMINIO_ORIGINAL="ad.${EMPRESA,,}.local"
fi

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
  log level = 1
  recycle:repository = $RECYCLE_REPOSITORY/%U
  recycle:excludedir = $RECYCLE_EXCLUDEDIR
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

echo "Aplicando mudanças..."

# Fazer backup do original
cp "$ORIGEM_CONF" "$BKP_FILE"
echo "✓ Backup criado: $BKP_FILE"

# Aplicar nova configuração
mv "$DESTINO_CONF" "$ORIGEM_CONF"
echo "✓ Nova configuração aplicada: $ORIGEM_CONF"
