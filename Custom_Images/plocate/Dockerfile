FROM debian:12-slim

# Metadados
LABEL maintainer="PlocateWebUI"
LABEL description="pLocate WebUI - Interface web segura para busca rápida de arquivos"
LABEL version="1.0"

# Variáveis de ambiente
ENV DEBIAN_FRONTEND=noninteractive
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_PID_FILE=/var/run/apache2.pid
ENV WEB_USERNAME=admin
ENV WEB_PASSWORD=admin123

# Instalar dependências
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apache2 \
    apache2-utils \
    plocate \
    sudo \
    python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Habilitar módulos Apache
RUN a2enmod cgi headers

# Criar estrutura de diretórios
RUN mkdir -p /var/www/plocate-web/cgi-bin \
    && mkdir -p /var/log/plocate-web \
    && mkdir -p /etc/apache2/auth

# Configurar sudoers para comandos plocate
RUN echo "www-data ALL=(root) NOPASSWD: /usr/bin/updatedb" >> /etc/sudoers.d/plocate-web && \
    echo "www-data ALL=(root) NOPASSWD: /usr/bin/locate" >> /etc/sudoers.d/plocate-web && \
    echo "www-data ALL=(root) NOPASSWD: /usr/bin/plocate" >> /etc/sudoers.d/plocate-web && \
    echo "www-data ALL=(root) NOPASSWD: /bin/find" >> /etc/sudoers.d/plocate-web && \
    echo "www-data ALL=(root) NOPASSWD: /bin/grep" >> /etc/sudoers.d/plocate-web && \
    echo "www-data ALL=(root) NOPASSWD: /usr/bin/du" >> /etc/sudoers.d/plocate-web && \
    echo "www-data ALL=(root) NOPASSWD: /usr/bin/stat" >> /etc/sudoers.d/plocate-web && \
    echo "www-data ALL=(root) NOPASSWD: /bin/wc" >> /etc/sudoers.d/plocate-web && \
    echo "www-data ALL=(root) NOPASSWD: /usr/bin/cut" >> /etc/sudoers.d/plocate-web && \
    chmod 440 /etc/sudoers.d/plocate-web

# Configurar Apache VirtualHost COM AUTENTICAÇÃO
RUN echo 'Listen 80' > /etc/apache2/ports.conf

COPY <<EOF /etc/apache2/sites-available/plocate-web.conf
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/plocate-web

    ScriptAlias /cgi-bin/ "/var/www/plocate-web/cgi-bin/"

    <Directory "/var/www/plocate-web/cgi-bin/">
        AuthType Basic
        AuthName "pLocate WebUI - Login Required"
        AuthUserFile /etc/apache2/auth/.htpasswd
        Require valid-user

        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        AddHandler cgi-script .cgi
        AllowOverride None
    </Directory>

    <Directory "/var/www/plocate-web">
        AuthType Basic
        AuthName "pLocate WebUI - Login Required"
        AuthUserFile /etc/apache2/auth/.htpasswd
        Require valid-user

        Options -Indexes +FollowSymLinks
        AllowOverride None
        DirectoryIndex index.html
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/plocate-web_error.log
    CustomLog \${APACHE_LOG_DIR}/plocate-web_access.log combined

    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
</VirtualHost>
EOF

# Interface HTML
COPY <<EOF /var/www/plocate-web/index.html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>pLocate WebUI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
            color: white;
            padding: 30px;
            text-align: center;
            position: relative;
        }
        .header h1 { font-size: 2.5em; margin-bottom: 10px; font-weight: 300; }
        .header p { font-size: 1.1em; opacity: 0.9; }
        .auth-badge {
            position: absolute;
            top: 15px;
            right: 20px;
            background: rgba(46, 204, 113, 0.9);
            padding: 8px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: 600;
        }
        .main-content { padding: 40px; }

        .search-section {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
        }

        .form-group { margin-bottom: 20px; }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #2c3e50;
            font-size: 16px;
        }
        .form-group input {
            width: 100%;
            padding: 15px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s ease;
        }
        .form-group input:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
        }

        .btn {
            background: #3498db;
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            transition: all 0.3s ease;
            margin-right: 10px;
            margin-bottom: 10px;
        }
        .btn:hover { background: #2980b9; transform: translateY(-2px); }
        .btn:disabled { background: #bdc3c7; cursor: not-allowed; transform: none; }

        .btn-secondary { background: #95a5a6; }
        .btn-secondary:hover { background: #7f8c8d; }

        .loading {
            display: none;
            text-align: center;
            padding: 30px;
        }
        .loading.active { display: block; }

        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #3498db;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin: 0 auto 15px;
        }
        @keyframes spin { 0%{transform:rotate(0deg);} 100%{transform:rotate(360deg);} }

        .result-container {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 10px;
            border-left: 4px solid #3498db;
            margin-top: 20px;
            display: none;
            max-height: 600px;
            overflow-y: auto;
        }
        .result-container.active { display: block; }

        .result-content {
            font-family: 'Courier New', monospace;
            background: #2c3e50;
            color: #ecf0f1;
            padding: 20px;
            border-radius: 8px;
            white-space: pre-wrap;
            word-break: break-all;
            line-height: 1.4;
        }

        .alert {
            padding: 15px 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            display: none;
            font-weight: 500;
        }
        .alert.active { display: block; }
        .alert-success {
            background: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }
        .alert-info {
            background: #d1ecf1;
            color: #0c5460;
            border-left: 4px solid #17a2b8;
        }

        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            text-align: center;
        }

        .stat-number {
            font-size: 2em;
            font-weight: bold;
            color: #3498db;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #7f8c8d;
            font-size: 0.9em;
        }

        .search-tips {
            background: #e8f4fd;
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid #3498db;
            margin-bottom: 20px;
        }

        .search-tips h3 {
            color: #2c3e50;
            margin-bottom: 10px;
        }

        .search-tips ul {
            color: #34495e;
            padding-left: 20px;
        }

        .search-tips li {
            margin-bottom: 5px;
        }

        @media (max-width: 768px) {
            .container { margin: 10px; }
            .main-content { padding: 20px; }
            .search-section { padding: 20px; }
            .auth-badge { position: static; margin-bottom: 10px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="auth-badge">🔒 Secure</div>
            <h1>🔍 pLocate WebUI</h1>
            <p>Interface Web Segura para Busca Rápida de Arquivos</p>
        </div>

        <div class="main-content">

            <!-- Estatísticas do Índice -->
            <div id="stats-section" class="stats" style="display: none;">
                <div class="stat-card">
                    <div id="stat-files" class="stat-number">-</div>
                    <div class="stat-label">Arquivos Indexados</div>
                </div>
                <div class="stat-card">
                    <div id="stat-size" class="stat-number">-</div>
                    <div class="stat-label">Tamanho do Banco</div>
                </div>
                <div class="stat-card">
                    <div id="stat-updated" class="stat-number">-</div>
                    <div class="stat-label">Última Atualização</div>
                </div>
            </div>

            <!-- Seção de Busca -->
            <div class="search-section">
                <h2 style="margin-bottom: 20px; color: #2c3e50;">🔍 Buscar Arquivos</h2>

                <div class="search-tips">
                    <h3>💡 Dicas de Busca:</h3>
                    <ul>
                        <li><strong>Termo simples:</strong> arquivo.txt</li>
                        <li><strong>Com espaços:</strong> "minha pasta"</li>
                        <li><strong>Wildcards:</strong> *.pdf ou arquivo*</li>
                        <li><strong>Case sensitive:</strong> MAIÚSCULA vs minúscula</li>
                    </ul>
                </div>

                <form id="searchForm">
                    <div class="form-group">
                        <label for="searchTerm">Termo de Busca:</label>
                        <input type="text" id="searchTerm" name="searchTerm" placeholder="Digite o nome do arquivo ou pasta..." required autofocus>
                    </div>

                    <button type="submit" class="btn" id="searchBtn">🔍 Buscar</button>
                    <button type="button" class="btn btn-secondary" onclick="updateIndex()">🔄 Atualizar Índice</button>
                    <button type="button" class="btn btn-secondary" onclick="showStats()">📊 Mostrar Estatísticas</button>
                </form>
            </div>

            <!-- Alertas -->
            <div id="alert" class="alert"></div>

            <!-- Loading -->
            <div id="loading" class="loading">
                <div class="spinner"></div>
                <p>Processando busca...</p>
            </div>

            <!-- Resultados -->
            <div id="resultContainer" class="result-container">
                <h4 style="margin-bottom: 15px; color: #2c3e50;">📋 Resultados da Busca:</h4>
                <div id="resultContent" class="result-content"></div>
            </div>
        </div>
    </div>

    <script>
        const CGI_URL = '/cgi-bin/plocate-search.cgi';

        // Elementos DOM
        const searchForm = document.getElementById('searchForm');
        const searchBtn = document.getElementById('searchBtn');
        const loading = document.getElementById('loading');
        const resultContainer = document.getElementById('resultContainer');
        const resultContent = document.getElementById('resultContent');
        const alert = document.getElementById('alert');
        const statsSection = document.getElementById('stats-section');

        // Event Listeners
        searchForm.addEventListener('submit', handleSearch);

        // Carregar estatísticas ao iniciar
        document.addEventListener('DOMContentLoaded', function() {
            showStats();
        });

        // Função principal de busca
        async function handleSearch(event) {
            event.preventDefault();

            const searchTerm = document.getElementById('searchTerm').value.trim();
            if (!searchTerm) {
                showAlert('Por favor, digite um termo de busca', 'error');
                return;
            }

            showLoading();
            hideAlert();
            hideResult();

            try {
                const formData = new URLSearchParams();
                formData.append('action', 'search');
                formData.append('searchTerm', searchTerm);

                const response = await fetch(CGI_URL, {
                    method: 'POST',
                    body: formData
                });

                const text = await response.text();
                hideLoading();

                if (text.trim()) {
                    showResult(text);
                    showAlert(\`Busca por "\${searchTerm}" concluída\`, 'success');
                } else {
                    showAlert('Nenhum resultado encontrado', 'info');
                }

            } catch (error) {
                hideLoading();
                showAlert('Erro na busca: ' + error.message, 'error');
            }
        }

        // Atualizar índice
        async function updateIndex() {
            showLoading();
            hideAlert();

            try {
                const formData = new URLSearchParams();
                formData.append('action', 'update-index');

                const response = await fetch(CGI_URL, {
                    method: 'POST',
                    body: formData
                });

                const text = await response.text();
                hideLoading();
                showResult(text);
                showAlert('Índice atualizado com sucesso', 'success');
                showStats();

            } catch (error) {
                hideLoading();
                showAlert('Erro ao atualizar índice: ' + error.message, 'error');
            }
        }

        // Mostrar estatísticas
        async function showStats() {
            try {
                const formData = new URLSearchParams();
                formData.append('action', 'stats');

                const response = await fetch(CGI_URL, {
                    method: 'POST',
                    body: formData
                });

                const text = await response.text();

                // Parse das estatísticas
                const lines = text.split('\\n');
                lines.forEach(line => {
                    if (line.includes('Arquivos indexados:')) {
                        const count = line.split(':')[1].trim();
                        document.getElementById('stat-files').textContent = count;
                    } else if (line.includes('Tamanho do banco:')) {
                        const size = line.split(':')[1].trim();
                        document.getElementById('stat-size').textContent = size;
                    } else if (line.includes('Última atualização:')) {
                        const updated = line.split(':')[1].trim();
                        document.getElementById('stat-updated').textContent = updated || 'N/A';
                    }
                });

                statsSection.style.display = 'grid';

            } catch (error) {
                console.error('Erro ao carregar estatísticas:', error);
            }
        }

        // Funções de UI
        function showLoading() {
            loading.classList.add('active');
            searchBtn.disabled = true;
        }

        function hideLoading() {
            loading.classList.remove('active');
            searchBtn.disabled = false;
        }

        function showResult(content) {
            resultContent.textContent = content;
            resultContainer.classList.add('active');
        }

        function hideResult() {
            resultContainer.classList.remove('active');
        }

        function showAlert(message, type) {
            alert.textContent = message;
            alert.className = \`alert alert-\${type} active\`;
            setTimeout(() => {
                hideAlert();
            }, 5000);
        }

        function hideAlert() {
            alert.classList.remove('active');
        }

        // Atalhos de teclado
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                hideAlert();
                hideResult();
            }
        });
    </script>
</body>
</html>
EOF

# Script CGI Backend
COPY <<'EOF' /var/www/plocate-web/cgi-bin/plocate-search.cgi
#!/bin/bash

# Cabeçalho HTTP
echo "Content-Type: text/plain; charset=UTF-8"
echo ""

# Variáveis
ACTION=""
SEARCH_TERM=""
LOCATE_DB="/var/lib/plocate/plocate.db"

# Parse de parâmetros CGI
parse_cgi_params() {
    if [ "$REQUEST_METHOD" = "POST" ]; then
        read -n "$CONTENT_LENGTH" QUERY_STRING
    fi

    IFS='&'
    for param in $QUERY_STRING; do
        key=$(echo "$param" | cut -d'=' -f1)
        value=$(echo "$param" | cut -d'=' -f2- | python3 -c "import sys, urllib.parse; print(urllib.parse.unquote_plus(sys.stdin.read().strip()))" 2>/dev/null || echo "$param" | cut -d'=' -f2-)

        case "$key" in
            "action") ACTION="$value" ;;
            "searchTerm") SEARCH_TERM="$value" ;;
        esac
    done
}

# Sanitizar entrada
sanitize_input() {
    SEARCH_TERM=$(echo "$SEARCH_TERM" | sed 's/[;&|`$(){}[\]*?<>]//g' | tr -d '\n\r' | cut -c1-100)
}

# Log de ações
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - User: ${REMOTE_USER:-unknown} - $1" >> /var/log/plocate-web/actions.log
}

# Encontrar caminhos de backup rsnapshot
find_backup_paths() {
    local paths=()

    # Verificar diretório /data (montado via volume)
    if [ -d "/data" ]; then
        paths+=("/data")
    fi

    # Procurar por configs rsnapshot
    for config_dir in "/data/srv/scripts" "/data/srv/containers/scripts"; do
        if [ -d "$config_dir" ]; then
            for config_file in "$config_dir"/rsnapshot*; do
                if [ -f "$config_file" ]; then
                    # Extrair snapshot_root
                    local snapshot_root=$(grep -E "^snapshot_root\s+" "$config_file" | sed -E 's/^snapshot_root\s+(.+)$/\1/' | tr -d '\t')
                    if [ -n "$snapshot_root" ] && [ -d "$snapshot_root" ]; then
                        paths+=("$snapshot_root")
                    fi

                    # Extrair backup paths
                    grep -E "^backup\s+" "$config_file" | sed -E 's/^backup\s+([^\t]+)\t.*/\1/' | tr -d '\t' | while read -r backup_path; do
                        if [ -n "$backup_path" ] && [ -d "$backup_path" ]; then
                            paths+=("$backup_path")
                        fi
                    done
                fi
            done
        fi
    done

    # Remover duplicatas
    printf '%s\n' "${paths[@]}" | sort -u
}

# Verificar e criar índice
check_and_create_index() {
    local paths=($(find_backup_paths))

    if [ ${#paths[@]} -eq 0 ]; then
        echo "❌ Nenhum caminho de backup encontrado!"
        echo "💡 Certifique-se de montar o volume em /data"
        echo ""
        echo "Exemplo de execução:"
        echo "docker run -v /seu/caminho:/data -v /var/locate:/var/lib/plocate plocate-web"
        return 1
    fi

    echo "📁 Caminhos encontrados para indexação:"
    for path in "${paths[@]}"; do
        echo "   - $path"
    done
    echo ""

    # Verificar se índice existe e se não está muito antigo
    if [ ! -f "$LOCATE_DB" ] || [ $(find "$LOCATE_DB" -mtime +1 2>/dev/null | wc -l) -gt 0 ]; then
        echo "🔄 Criando/atualizando índice do plocate..."
        echo "⏳ Esta operação pode demorar alguns minutos..."
        echo ""

        # Criar diretório se não existir
        mkdir -p "$(dirname "$LOCATE_DB")"

        # Criar string de caminhos
        local paths_string=""
        for path in "${paths[@]}"; do
            paths_string="$paths_string $path"
        done

        # Executar updatedb
        if sudo updatedb --localpaths="$paths_string" --output="$LOCATE_DB" 2>&1; then
            echo "✅ Índice criado com sucesso!"
            echo "📊 Localização: $LOCATE_DB"
        else
            echo "❌ Erro ao criar índice!"
            return 1
        fi
    else
        echo "✅ Índice já existe e está atualizado"
    fi
    echo ""

    return 0
}

# Buscar com plocate/locate
search_files() {
    local search_term="$1"
    local results_found=0

    echo "🔍 Buscando por: '$search_term'"
    echo "📂 Base de dados: $LOCATE_DB"
    echo "👤 Usuário: ${REMOTE_USER:-unknown}"
    echo ""

    if [ ! -f "$LOCATE_DB" ]; then
        echo "❌ Banco de dados não encontrado!"
        echo "💡 Execute 'Atualizar Índice' primeiro"
        return 1
    fi

    # Tentar diferentes padrões de busca
    local patterns=("*$search_term*" "*${search_term,,}*" "*${search_term^^}*")

    echo "📋 Resultados encontrados:"
    echo "----------------------------------------"

    for pattern in "${patterns[@]}"; do
        if command -v plocate >/dev/null 2>&1; then
            local results=$(plocate --database="$LOCATE_DB" "$pattern" 2>/dev/null)
        else
            local results=$(locate --database="$LOCATE_DB" "$pattern" 2>/dev/null)
        fi

        if [ -n "$results" ]; then
            echo "$results"
            results_found=1
            break
        fi
    done

    if [ $results_found -eq 0 ]; then
        echo "ℹ️  Nenhum arquivo/pasta encontrado"
        echo "💡 Dicas:"
        echo "   • Verifique a grafia do termo"
        echo "   • Use wildcards: arquivo* ou *.pdf"
        echo "   • O índice pode estar desatualizado"
    fi
    echo ""
}

# Mostrar estatísticas
show_stats() {
    if [ -f "$LOCATE_DB" ]; then
        echo "📊 Estatísticas do Índice Plocate:"
        echo "================================="

        local count=$(locate --database="$LOCATE_DB" "*" 2>/dev/null | wc -l || echo "0")
        local size=$(du -h "$LOCATE_DB" 2>/dev/null | cut -f1 || echo "N/A")
        local modified=$(stat -c '%y' "$LOCATE_DB" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1 || echo "N/A")

        echo "Arquivos indexados: $count"
        echo "Tamanho do banco: $size"
        echo "Última atualização: $modified"
        echo ""
        echo "📂 Localização: $LOCATE_DB"
        echo "👤 Usuário logado: ${REMOTE_USER:-unknown}"
    else
        echo "❌ Banco de dados não encontrado"
        echo "💡 Execute 'Atualizar Índice' para criar"
    fi
}

# Função principal
main() {
    parse_cgi_params
    sanitize_input

    log_action "Ação: $ACTION, Termo: $SEARCH_TERM"

    case "$ACTION" in
        "search")
            if [ -z "$SEARCH_TERM" ]; then
                echo "❌ Termo de busca é obrigatório"
                exit 1
            fi
            search_files "$SEARCH_TERM"
            ;;
        "update-index")
            check_and_create_index
            ;;
        "stats")
            show_stats
            ;;
        *)
            echo "❌ Ação não reconhecida: $ACTION"
            ;;
    esac
}

# Executar
main
EOF

# Configurar permissões
RUN chown -R www-data:www-data /var/www/plocate-web \
    && chmod 755 /var/www/plocate-web/cgi-bin/plocate-search.cgi \
    && touch /var/log/plocate-web/actions.log \
    && chown www-data:www-data /var/log/plocate-web/actions.log

# Desabilitar site padrão e habilitar plocate-web
RUN a2dissite 000-default && a2ensite plocate-web

# Script de entrada
COPY <<EOF /usr/local/bin/start.sh
#!/bin/bash
set -e

echo "🚀 Iniciando pLocate WebUI Seguro..."

# Verificar volumes
if [ ! -d "/data" ]; then
    echo "⚠️  Volume /data não montado!"
    echo "💡 Use: -v /seu/caminho:/data"
fi

if [ ! -d "/var/lib/plocate" ]; then
    echo "⚠️  Volume plocate não montado!"
    echo "💡 Use: -v plocate_db:/var/lib/plocate"
fi

# Configurar autenticação
mkdir -p /etc/apache2/auth
if [ ! -f "/etc/apache2/auth/.htpasswd" ]; then
    echo "📝 Criando usuário: \$WEB_USERNAME"
    htpasswd -cb /etc/apache2/auth/.htpasswd "\$WEB_USERNAME" "\$WEB_PASSWORD"
    echo "✅ Usuário criado!"
else
    echo "✅ Arquivo de senhas já existe"
fi

# Configurar permissões
chown www-data:www-data /etc/apache2/auth/.htpasswd
chmod 640 /etc/apache2/auth/.htpasswd

# Mostrar info de login
echo ""
echo "🔐 LOGIN INFO:"
echo "=============="
echo "URL: http://localhost"
echo "User: \$WEB_USERNAME"
echo "Pass: \$WEB_PASSWORD"
echo ""

# Iniciar Apache
echo "🌐 Iniciando servidor web..."
exec apache2ctl -D FOREGROUND
EOF

RUN chmod +x /usr/local/bin/start.sh

# Expor porta
EXPOSE 80

# Volumes para montar
VOLUME ["/data", "/var/lib/plocate"]

# Comando de entrada
ENTRYPOINT ["/usr/local/bin/start.sh"]
