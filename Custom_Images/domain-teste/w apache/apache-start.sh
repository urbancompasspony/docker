#!/bin/bash -ex

# apache-start.sh - Script para inicializar Apache com Samba CGI

echo "Iniciando Apache para Samba Web Admin..."

# Aguardar um pouco para o Samba estar pronto
sleep 5

# Verificar se diretórios existem
if [ ! -d "/var/www/samba-admin" ]; then
    mkdir -p /var/www/samba-admin/cgi-bin
    chown -R www-data:www-data /var/www/samba-admin
fi

# Verificar se CGI script existe
if [ ! -f "/var/www/samba-admin/cgi-bin/samba-admin.cgi" ]; then
    echo "AVISO: Script CGI não encontrado em /var/www/samba-admin/cgi-bin/samba-admin.cgi"
fi

# Verificar se index.html existe, se não criar um básico
if [ ! -f "/var/www/samba-admin/index.html" ]; then
    cat > /var/www/samba-admin/index.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Samba Domain Controller</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; text-align: center; }
        .card { background: #f8f9fa; padding: 20px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #3498db; }
        .btn { background: #3498db; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 5px; }
        .btn:hover { background: #2980b9; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏢 Samba Domain Controller</h1>
        <div class="card">
            <h3>Serviços Disponíveis</h3>
            <a href="/cgi-bin/samba-admin.cgi" class="btn">🔧 Administração Samba</a>
            <a href="http://localhost:631" class="btn">🖨️ CUPS (Impressoras)</a>
        </div>
        <div class="card">
            <h3>Informações do Sistema</h3>
            <p><strong>Dominio:</strong> ${DOMAIN:-Configurar}</p>
            <p><strong>Data/Hora:</strong> <span id="datetime"></span></p>
        </div>
    </div>
    <script>
        document.getElementById('datetime').textContent = new Date().toLocaleString('pt-BR');
        setInterval(() => {
            document.getElementById('datetime').textContent = new Date().toLocaleString('pt-BR');
        }, 1000);
    </script>
</body>
</html>
EOF
    chown www-data:www-data /var/www/samba-admin/index.html
fi

# Garantir permissões corretas
chown -R www-data:www-data /var/www/samba-admin
chmod 755 /var/www/samba-admin/cgi-bin/*.cgi 2>/dev/null || true

# Criar diretório de logs se não existir
mkdir -p /var/log/samba-cgi
chown www-data:www-data /var/log/samba-cgi
touch /var/log/samba-cgi/actions.log
chown www-data:www-data /var/log/samba-cgi/actions.log

echo "Apache configurado para Samba Web Admin"
echo "Acesso: http://[IP_DO_CONTAINER]"
echo "CGI: http://[IP_DO_CONTAINER]/cgi-bin/samba-admin.cgi"

# Iniciar Apache em foreground
exec /usr/sbin/apache2ctl -D FOREGROUND
