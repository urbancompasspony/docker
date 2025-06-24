
# Adicionar usuário
htpasswd /etc/apache2/auth/.htpasswd novouser

# Remover usuário  
htpasswd -D /etc/apache2/auth/.htpasswd usuario

# Listar usuários
cut -d: -f1 /etc/apache2/auth/.htpasswd

# Desativar autenticação temporariamente
./auth-toggle.sh
