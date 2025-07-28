#!/bin/bash

YAML_FILE="/srv/containers.yaml"

# Verifica se o arquivo existe
if [ ! -f "$YAML_FILE" ]; then
    echo "Erro: Arquivo $YAML_FILE não encontrado!"
    exit 1
fi

# Função para extrair nome_custom de containers com img_base = active-directory
get_ad_containers() {
    yq '.[] | select(.img_base == "active-directory") | .nome_custom' "$YAML_FILE" | tr '\n' ' '
}

# Função para extrair WEB_Pass de um container específico
get_web_pass() {
    local container_name="$1"
    yq ".${container_name}.WebPass" "$YAML_FILE"
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
    
    # Extrai a senha WebPass do YAML
    local WEB_PASS=$(get_web_pass "$NOMECONTAINER")
    if [ -z "$WEB_PASS" ]; then
        echo "Erro: Não foi possível encontrar WEB_PASS para $NOMECONTAINER"
        return 1
    fi
       
    docker exec "$NOMECONTAINER" bash -c "curl -sSL --silent https://raw.githubusercontent.com/urbancompasspony/docker/refs/heads/main/rsat-webui-samba/autoconfig.sh --output /tmp/autoconfig.sh; bash /tmp/autoconfig.sh"
    docker exec "$NOMECONTAINER" bash -c "curl -sSL --silent https://raw.githubusercontent.com/urbancompasspony/docker/refs/heads/main/rsat-webui-samba/auth-toggle.sh --output /tmp/auth-toggle.sh; mv /tmp/auth-toggle.sh /usr/bin/; chmod +x /usr/bin/auth-toggle.sh"
    docker exec "$NOMECONTAINER" bash -c "curl -sSL --silent https://raw.githubusercontent.com/urbancompasspony/docker/refs/heads/main/rsat-webui-samba/setup_auth.sh --output /tmp/setup_auth.sh; mv /tmp/setup_auth.sh /usr/bin/; chmod +x /usr/bin/setup_auth.sh"
    docker exec "$NOMECONTAINER" bash -c "curl -sSL --silent https://raw.githubusercontent.com/urbancompasspony/docker/refs/heads/main/Apache2/auth-togle-for-ad.sh --output auth-togle-for-ad.sh"
    
    docker exec "$NOMECONTAINER" bash -c "mkdir -p /etc/apache2/auth"
    docker exec "$NOMECONTAINER" bash -c "htpasswd -c /etc/apache2/auth/.htpasswd admin"
    docker exec "$NOMECONTAINER" bash -c "htpasswd -b /etc/apache2/auth/.htpasswd admin '$WEB_PASS'"
    docker exec "$NOMECONTAINER" bash -c "bash /auth-togle-for-ad.sh"
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
