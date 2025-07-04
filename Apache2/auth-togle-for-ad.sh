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

enable_auth

exit 1
