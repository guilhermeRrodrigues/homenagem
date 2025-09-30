#!/bin/bash

echo "=========================================="
echo "Teste do Servidor de Homenagens"
echo "=========================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para testar endpoint
test_endpoint() {
    local url=$1
    local description=$2
    
    echo -e "\n${YELLOW}Testando: $description${NC}"
    echo "URL: $url"
    
    response=$(curl -s -w "\n%{http_code}" "$url" 2>/dev/null)
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 200 ]; then
        echo -e "${GREEN}✓ Sucesso (HTTP $http_code)${NC}"
        echo "Resposta: $body"
    else
        echo -e "${RED}✗ Erro (HTTP $http_code)${NC}"
        echo "Resposta: $body"
    fi
}

# Testar endpoints locais
echo -e "\n${YELLOW}=== TESTES LOCAIS ===${NC}"
test_endpoint "http://localhost:8080/api/health" "Health Check"
test_endpoint "http://localhost:8080/api/debug" "Debug Info"
test_endpoint "http://localhost:8080/api/info" "App Info"
test_endpoint "http://localhost:8080/api/tributes" "Listar Homenagens"

# Testar endpoints externos
echo -e "\n${YELLOW}=== TESTES EXTERNOS ===${NC}"
test_endpoint "http://45.70.136.66:8080/api/health" "Health Check Externo"
test_endpoint "http://45.70.136.66:8080/api/debug" "Debug Info Externo"

# Verificar status do container
echo -e "\n${YELLOW}=== STATUS DO CONTAINER ===${NC}"
docker-compose ps

# Verificar portas em uso
echo -e "\n${YELLOW}=== PORTAS EM USO ===${NC}"
ss -tulpn | grep -E ":(80|8080|5000)" || echo "Nenhuma porta encontrada"

# Verificar firewall
echo -e "\n${YELLOW}=== STATUS DO FIREWALL ===${NC}"
sudo ufw status

echo -e "\n${GREEN}=========================================="
echo "Teste concluído!"
echo "==========================================${NC}"
