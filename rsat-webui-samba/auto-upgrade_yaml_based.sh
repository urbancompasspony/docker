#!/bin/bash

# Script para configurar containers com img_base = active-directory
# Lê /srv/containers.yaml e executa comandos nos containers encontrados

YAML_FILE="/srv/containers.yaml"

# Verifica se o arquivo existe
if [ ! -f "$YAML_FILE" ]; then
    echo "Erro: Arquivo $YAML_FILE não encontrado!"
    exit 1
fi

# Função para extrair nome_custom de containers com img_base = active-directory
get_ad_containers() {
    grep -B 10 -A 10 "img_base: active-directory" "$YAML_FILE" | \
    grep "nome_custom:" | \
    awk '{print $2}'
}

# Função para extrair ADM_Pass de um container específico
get_adm_pass() {
    local container_name="$1"
    # Encontra o bloco do container e extrai o ADM_Pass
    awk "
    /^${container_name}:/ { found=1; next }
    found && /^[a-zA-Z0-9_-]+:/ && !/^  / { found=0 }
    found && /ADM_Pass:/ { gsub(/^[ \t]*ADM_Pass:[ \t]*/, \"\"); print; found=0 }
    " "$YAML_FILE"
}

# Função para executar comandos no container
configure_container() {
    local NOMECONTAINER="$1"
    
    echo "Configurando container: $NOMECONTAINER"
    
    # Verifica se o container está rodando
    if ! docker ps --format "table {{.Names}}" | grep -q "^${NOMECONTAINER}$"; then
        echo "Aviso: Container $NOMECONTAINER não está rodando. Pulando..."
        return 1
    fi
    
    # Extrai a senha ADM_Pass do YAML
    local ADM_PASS=$(get_adm_pass "$NOMECONTAINER")
    if [ -z "$ADM_PASS" ]; then
        echo "Erro: Não foi possível encontrar ADM_Pass para $NOMECONTAINER"
        return 1
    fi
    
    echo "  - Senha ADM_Pass encontrada para $NOMECONTAINER"
    
    # Executa os comandos de configuração
    echo "  - Executando autoconfig.sh..."
    docker exec "$NOMECONTAINER" bash -c "curl -sSL https://raw.githubusercontent.com/urbancompasspony/docker/refs/heads/main/rsat-webui-samba/autoconfig.sh | bash"
    
    echo "  - Executando auth-togle-for-ad.sh..."
    docker exec "$NOMECONTAINER" bash -c "curl -sSL https://raw.githubusercontent.com/urbancompasspony/docker/refs/heads/main/Apache2/auth-togle-for-ad.sh | bash"
    
    echo "  - Baixando auth-toggle.sh..."
    docker exec "$NOMECONTAINER" bash -c "curl -sSL https://raw.githubusercontent.com/urbancompasspony/docker/refs/heads/main/rsat-webui-samba/auth-toggle.sh > auth-toggle.sh"
    
    echo "  - Movendo auth-toggle.sh para /usr/bin/..."
    docker exec "$NOMECONTAINER" bash -c "mv auth-toggle.sh /usr/bin/; chmod +x /usr/bin/auth-toggle.sh"
    
    echo "  - Baixando setup_auth.sh..."
    docker exec "$NOMECONTAINER" bash -c "curl -sSL https://raw.githubusercontent.com/urbancompasspony/docker/refs/heads/main/rsat-webui-samba/setup_auth.sh > setup_auth.sh"
    
    echo "  - Movendo setup_auth.sh para /usr/bin/..."
    docker exec "$NOMECONTAINER" bash -c "mv setup_auth.sh /usr/bin/; chmod +x /usr/bin/setup_auth.sh"
    
    echo "  - Criando diretório de autenticação..."
    docker exec "$NOMECONTAINER" bash -c "mkdir -p /etc/apache2/auth"
    
    echo "  - Criando arquivo .htpasswd..."
    docker exec "$NOMECONTAINER" bash -c "htpasswd -c /etc/apache2/auth/.htpasswd admin"
    
    echo "  - Configurando senha do admin com ADM_Pass..."
    docker exec "$NOMECONTAINER" bash -c "htpasswd -b /etc/apache2/auth/.htpasswd admin '$ADM_PASS'"
    
    echo "Container $NOMECONTAINER configurado com sucesso!"
    echo "----------------------------------------"
}

# Main
echo "Iniciando configuração dos containers Active Directory..."
echo "Lendo arquivo: $YAML_FILE"
echo "========================================="

# Obtém lista de containers AD
AD_CONTAINERS=$(get_ad_containers)

if [ -z "$AD_CONTAINERS" ]; then
    echo "Nenhum container com img_base: active-directory encontrado."
    exit 0
fi

# Loop através dos containers encontrados
for CONTAINER in $AD_CONTAINERS; do
    configure_container "$CONTAINER"
done

echo "Configuração concluída para todos os containers!"
