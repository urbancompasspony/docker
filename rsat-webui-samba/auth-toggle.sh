#!/bin/bash

# auth-toggle.sh - Script para ativar/desativar autenticação do Samba Admin

set -e

# Verificar se é root
if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root"
   exit 1
fi

# Função para mostrar status atual
show_status() {
    if grep -q "AuthType Basic" /etc/apache2/sites-available/samba-admin.conf 2>/dev/null; then
        echo "🔐 AUTENTICAÇÃO: ATIVADA"
        if [ -f "/etc/apache2/auth/.htpasswd" ]; then
            user_count=$(wc -l < /etc/apache2/auth/.htpasswd)
            echo "👥 Usuários cadastrados: $user_count"
            echo "📋 Lista de usuários:"
            cut -d: -f1 /etc/apache2/auth/.htpasswd | sed 's/^/   - /'
        fi
    else
        echo "🔓 AUTENTICAÇÃO: DESATIVADA (Acesso livre)"
    fi
}

# Função para ativar autenticação
enable_auth() {
    if grep -q "AuthType Basic" /etc/apache2/sites-available/samba-admin.conf; then
        echo "✓ Autenticação já está ativada!"
        return
    fi

    echo "Ativando autenticação..."

    # Fazer backup
    cp /etc/apache2/sites-available/samba-admin.conf /etc/apache2/sites-available/samba-admin.conf.backup.$(date +%Y%m%d_%H%M%S)

    # Aplicar configuração com autenticação
    cat > /etc/apache2/sites-available/samba-admin.conf << 'EOF'
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/samba-admin
    
    ScriptAlias /cgi-bin/ "/var/www/samba-admin/cgi-bin/"
    
    <Directory "/var/www/samba-admin/cgi-bin/">
        AuthType Basic
        AuthName "Samba Administration - Login Required"
        AuthUserFile /etc/apache2/auth/.htpasswd
        Require valid-user
        
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        AddHandler cgi-script .cgi .sh .pl .py
        AllowOverride None
    </Directory>
    
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
    
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
</VirtualHost>
EOF

    service apache2 restart
    echo "✓ Autenticação ATIVADA!"
}

# Função para desativar autenticação
disable_auth() {
    if ! grep -q "AuthType Basic" /etc/apache2/sites-available/samba-admin.conf; then
        echo "✓ Autenticação já está desativada!"
        return
    fi

    echo "Desativando autenticação..."

    # Fazer backup
    cp /etc/apache2/sites-available/samba-admin.conf /etc/apache2/sites-available/samba-admin.conf.backup.$(date +%Y%m%d_%H%M%S)

    # Aplicar configuração SEM autenticação (configuração original do autoconfig.sh)
    cat > /etc/apache2/sites-available/samba-admin.conf << 'EOF'
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/samba-admin
    
    ScriptAlias /cgi-bin/ "/var/www/samba-admin/cgi-bin/"
    
    <Directory "/var/www/samba-admin/cgi-bin/">
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        AddHandler cgi-script .cgi .sh .pl .py
        Require all granted
        AllowOverride None
    </Directory>
    
    <Directory "/var/www/samba-admin">
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
        DirectoryIndex index.html
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/samba-admin_error.log
    CustomLog ${APACHE_LOG_DIR}/samba-admin_access.log combined
    
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
</VirtualHost>
EOF

    service apache2 restart
    echo "✓ Autenticação DESATIVADA! (Acesso livre)"
}

# Função para gerenciar usuários
manage_users() {
    if [ ! -f "/etc/apache2/auth/.htpasswd" ]; then
        echo "Arquivo de senhas não existe. Criando..."
        mkdir -p /etc/apache2/auth
        touch /etc/apache2/auth/.htpasswd
        chown www-data:www-data /etc/apache2/auth/.htpasswd
        chmod 640 /etc/apache2/auth/.htpasswd
    fi

    while true; do
        echo ""
        echo "=== GERENCIAMENTO DE USUÁRIOS ==="
        echo "1) Listar usuários"
        echo "2) Adicionar usuário"
        echo "3) Remover usuário"
        echo "4) Alterar senha de usuário"
        echo "5) Voltar"
        echo -n "Escolha uma opção: "
        read choice

        case $choice in
            1)
                echo ""
                if [ -s "/etc/apache2/auth/.htpasswd" ]; then
                    echo "👥 Usuários cadastrados:"
                    cut -d: -f1 /etc/apache2/auth/.htpasswd | sed 's/^/   - /'
                else
                    echo "Nenhum usuário cadastrado"
                fi
                ;;
            2)
                echo -n "Nome do novo usuário: "
                read username
                if [ -n "$username" ]; then
                    if grep -q "^$username:" /etc/apache2/auth/.htpasswd 2>/dev/null; then
                        echo "Usuário '$username' já existe!"
                    else
                        htpasswd /etc/apache2/auth/.htpasswd "$username"
                        echo "✓ Usuário '$username' adicionado!"
                    fi
                fi
                ;;
            3)
                echo -n "Nome do usuário para remover: "
                read username
                if [ -n "$username" ]; then
                    if htpasswd -D /etc/apache2/auth/.htpasswd "$username" 2>/dev/null; then
                        echo "✓ Usuário '$username' removido!"
                    else
                        echo "Usuário '$username' não encontrado!"
                    fi
                fi
                ;;
            4)
                echo -n "Nome do usuário para alterar senha: "
                read username
                if [ -n "$username" ]; then
                    if grep -q "^$username:" /etc/apache2/auth/.htpasswd 2>/dev/null; then
                        htpasswd /etc/apache2/auth/.htpasswd "$username"
                        echo "✓ Senha de '$username' alterada!"
                    else
                        echo "Usuário '$username' não encontrado!"
                    fi
                fi
                ;;
            5)
                break
                ;;
            *)
                echo "Opção inválida!"
                ;;
        esac
    done
}

# Menu principal
while true; do
    clear
    echo "========================================"
    echo "  SAMBA ADMIN - GERENCIADOR DE AUTH"
    echo "========================================"
    echo ""
    show_status
    echo ""
    echo "1) Ativar autenticação"
    echo "2) Desativar autenticação"
    echo "3) Gerenciar usuários"
    echo "4) Ver logs de acesso"
    echo "5) Testar configuração Apache"
    echo "6) Sair"
    echo ""
    echo -n "Escolha uma opção: "
    read choice

    case $choice in
        1)
            enable_auth
            read -p "Pressione Enter para continuar..."
            ;;
        2)
            echo -n "Tem certeza que deseja desativar a autenticação? (s/N): "
            read confirm
            if [[ $confirm =~ ^[Ss]$ ]]; then
                disable_auth
            else
                echo "Operação cancelada."
            fi
            read -p "Pressione Enter para continuar..."
            ;;
        3)
            manage_users
            ;;
        4)
            echo ""
            echo "=== LOGS DE ACESSO (últimas 20 linhas) ==="
            tail -20 /var/log/apache2/samba-admin_access.log 2>/dev/null || echo "Nenhum log encontrado"
            echo ""
            read -p "Pressione Enter para continuar..."
            ;;
        5)
            echo ""
            echo "=== TESTE DE CONFIGURAÇÃO ==="
            if apache2ctl configtest; then
                echo "✓ Configuração Apache OK!"
            else
                echo "✗ Erro na configuração Apache!"
            fi
            echo ""
            read -p "Pressione Enter para continuar..."
            ;;
        6)
            echo "Saindo..."
            exit 0
            ;;
        *)
            echo "Opção inválida!"
            read -p "Pressione Enter para continuar..."
            ;;
    esac
done
