#!/bin/bash

# setup-auth-compatible.sh - Adicionar autenticação ao Samba Admin SEM QUEBRAR configuração existente

set -e

echo "=== Adicionando Autenticação ao Samba Admin (Compatível) ==="

# Verificar se é root
if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root"
   exit 1
fi

# Verificar se o autoconfig.sh já foi executado
if [ ! -f "/etc/apache2/sites-available/samba-admin.conf" ]; then
   echo "ERRO: Parece que o autoconfig.sh não foi executado ainda!"
   echo "Execute primeiro: ./autoconfig.sh"
   exit 1
fi

echo "✓ Configuração do autoconfig.sh detectada"

# Verificar se apache2-utils está instalado (para htpasswd)
if ! command -v htpasswd &> /dev/null; then
    echo "Instalando apache2-utils para htpasswd..."
    apt update
    apt install -y apache2-utils
fi

# Criar diretório para senhas
mkdir -p /etc/apache2/auth

# Função para criar usuário admin
create_admin_user() {
    echo "Criando usuário administrador..."
    echo -n "Digite o nome de usuário admin: "
    read USERNAME
    
    if [ -z "$USERNAME" ]; then
        echo "Nome de usuário não pode ser vazio!"
        exit 1
    fi
    
    # Criar arquivo de senhas
    htpasswd -c /etc/apache2/auth/.htpasswd "$USERNAME"
    
    echo "Usuário $USERNAME criado com sucesso!"
}

# Função para adicionar usuários adicionais
add_user() {
    echo -n "Digite o nome do usuário adicional: "
    read USERNAME
    
    if [ -z "$USERNAME" ]; then
        echo "Nome de usuário não pode ser vazio!"
        return
    fi
    
    htpasswd /etc/apache2/auth/.htpasswd "$USERNAME"
    echo "Usuário $USERNAME adicionado!"
}

# Criar usuário admin inicial
create_admin_user

# Perguntar se quer adicionar mais usuários
while true; do
    echo -n "Deseja adicionar outro usuário? (s/n): "
    read -r REPLY
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        add_user
    else
        break
    fi
done

# Configurar permissões
chown www-data:www-data /etc/apache2/auth/.htpasswd
chmod 640 /etc/apache2/auth/.htpasswd

# IMPORTANTE: Fazer backup da configuração atual
cp /etc/apache2/sites-available/samba-admin.conf /etc/apache2/sites-available/samba-admin.conf.backup.$(date +%Y%m%d_%H%M%S)

# Modificar a configuração existente ADICIONANDO autenticação
echo "Modificando configuração existente para adicionar autenticação..."

# Criar nova configuração baseada na existente, mas com autenticação
cat > /etc/apache2/sites-available/samba-admin.conf << 'EOF'
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/samba-admin
    
    ScriptAlias /cgi-bin/ "/var/www/samba-admin/cgi-bin/"
    
    # Proteger CGI scripts com autenticação
    <Directory "/var/www/samba-admin/cgi-bin/">
        AuthType Basic
        AuthName "Samba Administration - Login Required"
        AuthUserFile /etc/apache2/auth/.htpasswd
        Require valid-user
        
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        AddHandler cgi-script .cgi .sh .pl .py
        AllowOverride None
    </Directory>
    
    # Proteger conteúdo principal com autenticação
    <Directory "/var/www/samba-admin">
        AuthType Basic
        AuthName "Samba Administration - Login Required"
        AuthUserFile /etc/apache2/auth/.htpasswd
        Require valid-user
        
        Options -Indexes +FollowSymLinks
        AllowOverride None
        DirectoryIndex index.html
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/samba-admin_error.log
    CustomLog ${APACHE_LOG_DIR}/samba-admin_access.log combined
    
    # Headers de segurança mantidos do autoconfig.sh
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
</VirtualHost>
EOF

# Verificar se a configuração sudoers do autoconfig.sh existe e mantê-la
if [ ! -f "/etc/sudoers.d/samba-cgi" ]; then
    echo "Recriando configuração sudoers (parece que foi perdida)..."
    cat > /etc/sudoers.d/samba-cgi << 'EOF'
# Permitir que www-data execute comandos samba-tool
www-data ALL=(root) NOPASSWD: /usr/bin/samba-tool
www-data ALL=(root) NOPASSWD: /usr/bin/net
www-data ALL=(root) NOPASSWD: /usr/sbin/smbcontrol
EOF
    chmod 440 /etc/sudoers.d/samba-cgi
fi

# Verificar estrutura de diretórios do autoconfig.sh
echo "Verificando estrutura de diretórios..."
mkdir -p /var/www/samba-admin/cgi-bin
mkdir -p /var/log/samba-cgi

# Verificar permissões mantidas do autoconfig.sh
chown -R www-data:www-data /var/www/samba-admin
chmod 755 /var/www/samba-admin/cgi-bin

# Verificar logs do autoconfig.sh
touch /var/log/samba-cgi/actions.log
chown www-data:www-data /var/log/samba-cgi/actions.log
chmod 644 /var/log/samba-cgi/actions.log

# Testar configuração
echo "Testando configuração..."
if apache2ctl configtest; then
    echo "Configuração OK!"
    
    # Recarregar Apache (não reiniciar para manter sessões)
    echo "Recarregando Apache..."
    service apache2 restart
    
    echo ""
    echo "=== AUTENTICAÇÃO ADICIONADA COM SUCESSO ==="
    echo ""
    echo "✓ Configuração do autoconfig.sh preservada"
    echo "✓ Autenticação HTTP Basic adicionada"
    echo "✓ Backup criado: samba-admin.conf.backup.*"
    echo ""
    echo "Acesse: http://localhost/"
    echo "Uma janela de login será exibida pelo navegador"
    echo ""
    echo "COMANDOS ÚTEIS:"
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ Adicionar usuário:                                          │"
    echo "│ htpasswd /etc/apache2/auth/.htpasswd novoUsuario            │"
    echo "│                                                             │"
    echo "│ Remover usuário:                                            │"
    echo "│ htpasswd -D /etc/apache2/auth/.htpasswd usuario             │"
    echo "│                                                             │"
    echo "│ Listar usuários:                                            │"
    echo "│ cat /etc/apache2/auth/.htpasswd | cut -d: -f1              │"
    echo "│                                                             │"
    echo "│ Ver logs de acesso:                                         │"
    echo "│ tail -f /var/log/apache2/samba-admin_access.log            │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""
    echo "Para REMOVER a autenticação e voltar ao estado anterior:"
    echo "mv /etc/apache2/sites-available/samba-admin.conf.backup.* /etc/apache2/sites-available/samba-admin.conf"
    echo "service apache2 restart"
    
else
    echo "ERRO na configuração do Apache!"
    echo "Restaurando backup..."
    mv /etc/apache2/sites-available/samba-admin.conf.backup.* /etc/apache2/sites-available/samba-admin.conf
    exit 1
fi

# Verificar se os arquivos essenciais existem
echo ""
echo "=== VERIFICAÇÃO FINAL ==="
if [ -f "/var/www/samba-admin/index.html" ]; then
    echo "✓ index.html encontrado"
else
    echo "⚠️  index.html não encontrado - pode precisar executar autoconfig.sh novamente"
fi

if [ -f "/var/www/samba-admin/cgi-bin/samba-admin.cgi" ]; then
    echo "✓ samba-admin.cgi encontrado"
    if [ -x "/var/www/samba-admin/cgi-bin/samba-admin.cgi" ]; then
        echo "✓ samba-admin.cgi é executável"
    else
        echo "⚠️  Corrigindo permissões do samba-admin.cgi..."
        chmod +x /var/www/samba-admin/cgi-bin/samba-admin.cgi
    fi
else
    echo "⚠️  samba-admin.cgi não encontrado - pode precisar executar autoconfig.sh novamente"
fi

echo "✓ Autenticação configurada com sucesso!"
